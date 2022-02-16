function vcid_main(datadir)

% add FSL to libraries
setenv('LD_LIBRARY_PATH',[getenv('LD_LIBRARY_PATH')  ':/usr/lib/fsl/5.0']);
getenv('LD_LIBRARY_PATH')
PAR = setparameter(datadir); % specify where the data is located. this is the only param for now, but there could be others, e.g. slicetime, etc.

batch_segment(PAR); % Segment the anatomical images.
batch_create_mask(PAR);
batch_extract_M0(PAR); % In the M0 series, only the first one is M0.
batch_realign(PAR);  
batch_coreg_asl2MPRAGE(PAR);
batch_CBF_computation(PAR);
batch_smooth_CBF(PAR);
batch_fnirt(PAR); 
batch_reslice_CBF_t1space(PAR); %%% Reslice the CBF maps and the c1,2,3 in the ASL space to the T1 space
batch_MNI_2_sub_masks(PAR)

end 