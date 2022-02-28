FROM ubuntu:16.04
MAINTAINER Will Tackett <william.tackett@pennmedicine.upenn.edu>

#Remove expired LetsEncrypt cert
ENV REQUESTS_CA_BUNDLE "/etc/ssl/certs/ca-certificates.crt"

# Prepare environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    curl \
                    bzip2 \
                    ca-certificates \
                    xvfb \
                    cython3 \
                    build-essential \
                    autoconf \
                    wget \
                    libtool \
                    pkg-config \
                    jq \
                    zip \
                    unzip \
                    nano \
                    default-jdk \
                    git && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y --no-install-recommends \
                    nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Installing Neurodebian packages (FSL, AFNI, git)

# Pre-cache neurodebian key
COPY neurodeb/neurodebian.gpg /usr/local/etc/neurodebian.gpg

RUN curl -sSL "http://neuro.debian.net/lists/$( lsb_release -c | cut -f2 ).us-ca.full" >> /etc/apt/sources.list.d/neurodebian.sources.list && \
    apt-key add /usr/local/etc/neurodebian.gpg && \
    (apt-key adv --refresh-keys --keyserver hkp://ha.pool.sks-keyservers.net 0xA5D32F012649A5A9 || true)

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    fsl-core=5.0.9-5~nd16.04+1 \
                    fsl-mni152-templates=5.0.7-2 \
                    afni=16.2.07~dfsg.1-5~nd16.04+1 \
                    git-annex-standalone && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV FSLDIR=/usr/share/fsl/5.0 \
    PATH=/usr/share/fsl/5.0:${PATH} \
    PATH=/usr/share/fsl/5.0/bin:${PATH} \
    FSLOUTPUTTYPE="NIFTI_GZ" \
    FSLMULTIFILEQUIT="TRUE" \
    LD_LIBRARY_PATH="/usr/lib/fsl/5.0:$LD_LIBRARY_PATH"


#ENV PATH="${FSLDIR}/bin:$PATH"
#ENV FSLOUTPUTTYPE="NIFTI_GZ"

# Install zip and jq
RUN apt-get install zip unzip -y
RUN apt-get install -y jq

# Make directory for code
ENV BASEDIR /opt/base
RUN mkdir -p ${BASEDIR}

# Install MCR. Install path: usr/local/MATLAB/MATLAB_Runtime/v99
RUN mkdir -p /opt/mcr/
RUN wget -O /opt/mcr/mcr.zip http://ssd.mathworks.com/supportfiles/downloads/R2020b/Release/0/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2020b_glnxa64.zip
RUN unzip /opt/mcr/mcr.zip -d opt/mcr
RUN /opt/mcr/install -mode silent -agreeToLicense yes

# Install libs
RUN apt-get -y install libxmu6
#ENV LD_LIBRARY_PATH="/usr/local/MATLAB/MATLAB_Runtime/v910/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v910/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v910/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v910/extern/bin/glnxa64:$LD_LIBRARY_PATH"
ENV LD_LIBRARY_PATH="/usr/local/MATLAB/v99/runtime/glnxa64:/usr/local/MATLAB/v99/bin/glnxa64:/usr/local/MATLAB/v99/sys/os/glnxa64:/usr/local/MATLAB/v99/extern/bin/glnxa64:$LD_LIBRARY_PATH"

# Copy stuff over & change permissions
COPY neurodeb ${BASEDIR}/
COPY vcid_asl_pipeline ${BASEDIR}/
COPY run.sh ${BASEDIR}/
COPY src ${BASEDIR}/
RUN chmod -R 777 ${BASEDIR}


### GEAR STUFF
# Installing and setting up miniconda
RUN curl -sSLO https://repo.continuum.io/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh && \
    bash Miniconda3-4.5.11-Linux-x86_64.sh -b -p /usr/local/miniconda && \
    rm Miniconda3-4.5.11-Linux-x86_64.sh

ENV PATH=/usr/local/miniconda/bin:$PATH \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONNOUSERSITE=1

# Installing precomputed python packages
#RUN conda install -y python=3.7.1

RUN pip install --upgrade pip
RUN pip install 'flywheel-sdk==12.*'
RUN pip install pybids
RUN pip install --no-cache fw-heudiconv==0.3.3
RUN pip install pathlib

# Make directory for flywheel spec (v0)
ENV FLYWHEEL /flywheel/v0
RUN mkdir -p ${FLYWHEEL}

# Install libs
#RUN apt-get -y install libxmu6

# Copy stuff over
ENV FLYWHEEL /flywheel/v0
RUN mkdir -p ${FLYWHEEL}
COPY run.py ${FLYWHEEL}/run.py
COPY manifest.json ${FLYWHEEL}/manifest.json
RUN chmod 777 ${FLYWHEEL}/*
RUN chmod 777 /opt/base/

# ENV preservation for Flywheel Engine
RUN env -u HOSTNAME -u PWD | \
  awk -F = '{ print "export " $1 "=\"" $2 "\"" }' > ${FLYWHEEL}/docker-env.sh
RUN chmod +x ${FLYWHEEL}/docker-env.sh

# Configure entrypoints-
ENTRYPOINT ["python3 /flywheel/v0/run.py"]
