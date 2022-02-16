function batch_CBF_computation(PAR,indx)

if nargin<2
    indx = 1:PAR.nsubs;
end



fprintf('------------------------------------------------------------------')
fprintf('\nCOMPUTING CBF\n');
fprintf('------------------------------------------------------------------\n\n')

for subno = indx
    fprintf('\n------------------------------------------------------------------\n')
    fprintf('CBF computation for %s\n',PAR.subject(subno).subid);
    for sesno = 1:length(PAR.subject(subno).asldir)
        
        if isempty(PAR.subject(subno).asldir{sesno})
            continue;
        end
        
        P = spm_select('FPlist',PAR.subject(subno).asldir{sesno},'meanCBF');
        if ~isempty(P)
            continue;
        end
        
        %%% Smooth M0
        if isfield(PAR.subject(subno),'M0dir')
            sM0loc = my_spm_select('FPlist',PAR.subject(subno).asldir{sesno},['^srASLspace_mean' PAR.M0prefix{sesno} '.*.nii']);
            if isempty(sM0loc)
                M0loc = my_spm_select('FPlist',PAR.subject(subno).asldir{sesno},['^rASLspace_mean' PAR.M0prefix{sesno} '.*.nii']);
                sM0loc = fullfile(spm_str_manip(M0loc,'H'),['s' spm_str_manip(M0loc,'t')]);
                spm_smooth(M0loc,sM0loc,PAR.FWHM);
            end
        else
            sM0loc = my_spm_select('FPlist',PAR.subject(subno).asldir{sesno},['^sr' PAR.aslprefix{sesno} '.*.nii']);
            if isempty(sM0loc)
                M0loc = my_spm_select('ExtFPlist',PAR.subject(subno).asldir{sesno},['^r' PAR.aslprefix{sesno} '.*.nii']);
                for s = 1:size(M0loc)
                    sM0loc = fullfile(spm_str_manip(M0loc(s,:),'H'),['s' spm_str_manip(M0loc(s,:),'t')]);
                    spm_smooth(M0loc(s,:),sM0loc,PAR.FWHM);
                end
                sM0loc = my_spm_select('FPlist',PAR.subject(subno).asldir{sesno},['^sr' PAR.aslprefix{sesno} '.*.nii']);
            end
            
        end
        
        M0img = spm_read_vols(spm_vol(sM0loc));
        
        maskloc = my_spm_select('FPlist',PAR.subject(subno).asldir{sesno},'^rbk_mask.*nii');
        mask = spm_read_vols(spm_vol(maskloc))>0;
        
        EPIloc = my_spm_select('FPlist',PAR.subject(subno).asldir{sesno},['^r' PAR.aslprefix{sesno} '.nii']); % .gz WT 02/04/2022
        v = spm_vol(EPIloc);
        EPI = spm_read_vols(v);
        
        lambda  = PAR.ASL.lambda;
        T1b     = PAR.ASL.T1blood;
        alpha   = PAR.ASL.alpha;
        M0scale = PAR.ASL.M0scale;
        PLD     = PAR.ASL.PLD{sesno};
        tau     = PAR.ASL.LabelingTime{sesno};
        
        if isfield(PAR.ASL,'Slicetime')
            Slicetime = PAR.ASL.Slicetime;
        else
            Slicetime = 0;
        end
        slicetimearray=ones(v(1).dim(1)*v(1).dim(2),v(1).dim(3));
        for sss=1:v(1).dim(3)
            slicetimearray(:,sss)=slicetimearray(:,sss).*(sss-1)*Slicetime;
        end
        slicetimearray=reshape(slicetimearray,v(1).dim(1),v(1).dim(2),v(1).dim(3));
        
        
        PLD=PLD+slicetimearray;
        
        cbf_factor = 6000.0 .* lambda .* exp(PLD ./ T1b) ./ ( 2 .* alpha .* M0scale .* T1b .* (1 - exp(-tau ./ T1b)) ); %MRM White Paper 2014
        
        npairs = floor(size(EPI,4)/2);
        EPI = EPI(:,:,:,1:(2*npairs));
        meanPerf = mean(EPI(:,:,:,2:2:end) - EPI(:,:,:,1:2:end),4);
        if mean(meanPerf(mask&(~isnan(meanPerf))))>=0
            %if LabelFirst ==1
            labimgs = EPI(:,:,:,1:2:end);
            conimgs = EPI(:,:,:,2:2:end);
            if size(M0img,4)~=1
                M0img = M0img(:,:,:,2:2:end);
            else
                M0img = repmat(M0img,[1 1 1 npairs]);
            end
        else
            labimgs = EPI(:,:,:,2:2:end);
            conimgs = EPI(:,:,:,1:2:end);
            if size(M0img,4)~=1
                M0img = M0img(:,:,:,1:2:end);
            else
                M0img = repmat(M0img,[1 1 1 npairs]);
            end
            
        end
        
        perfimgs = conimgs(:,:,:,1:npairs) - labimgs(:,:,:,1:npairs);
        
        
        
        %Compute CBF images
        cbfimgs = repmat(cbf_factor, [1 1 1 size(perfimgs,4)]) .* perfimgs ./ M0img ;
        
        %to avoid NaN values
        % combmaskimg = repmat((maskimg == 0 | M0img == 0), [ 1 1 1 npairs]);  %
        % Don't want to mask the CBFImgs before smoothing
        combmaskimg = repmat((any(M0img==0,4) | ~mask), [ 1 1 1 npairs]);
        cbfimgs(combmaskimg | isnan(cbfimgs)) = 0;
        
        
        vo=v(1);
        vo.fname = fullfile(PAR.subject(subno).asldir{sesno},['meanCBF_' spm_str_manip(v(1).fname,'t')]);
        vo.dt = [16 0];
        meanCBF = mean(cbfimgs,4);
        spm_write_vol(vo,meanCBF);
        
        
        vo.fname = fullfile(PAR.subject(subno).asldir{sesno},['cbf_0_' spm_str_manip(v(1).fname,'t')]);
        
        for k=1:npairs
            vo.n = [k,1];
            spm_write_vol(vo,cbfimgs(:,:,:,k));
        end
        fprintf('Intracranial CBF : %0.2f\n',mean(meanCBF(mask)))
        compress_nii_files(PAR.subject(subno).asldir{sesno})
    end
end
