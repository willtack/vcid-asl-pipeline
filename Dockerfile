FROM ubuntu:16.04
MAINTAINER Will Tackett <william.tackett@pennmedicine.upenn.edu>

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
RUN mkdir /opt/mcr/
RUN wget -O /opt/mcr/mcr.zip http://ssd.mathworks.com/supportfiles/downloads/R2020b/Release/0/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2020b_glnxa64.zip
RUN unzip /opt/mcr/mcr.zip -d opt/mcr
RUN opt/mcr/install -mode silent -agreeToLicense yes

# Install libs
RUN apt-get -y install libxmu6

# Copy stuff over & change permissions
COPY . ${BASEDIR}/
RUN chmod +x ${BASEDIR}/*

# Configure entrypoints-
ENTRYPOINT ["/bin/bash", "/opt/base/run.sh"]
