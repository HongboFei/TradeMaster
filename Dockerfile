# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Install essential dependencies and Miniconda in one step
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    ca-certificates cmake git curl libopenmpi-dev python3-dev zlib1g-dev \
    libgl1-mesa-glx libglib2.0-0 libgtk2.0-dev swig && \
    rm -rf /var/lib/apt/lists/* && \
    curl -o ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

# Set environment variables for Conda
ENV PATH="/opt/conda/bin:$PATH"

# Create Conda environment with Python 3.9
RUN conda update -n base -c defaults conda -y && \
    conda create --prefix /opt/conda/envs/TradeMaster python=3.9 -y

# Use bash shell so conda activation works
SHELL ["/bin/bash", "-c"]

# Set Conda environment variables
ENV CONDA_DEFAULT_ENV=TradeMaster
ENV PATH="/opt/conda/envs/TradeMaster/bin:$PATH"

# Clone TradeMaster repository and switch to 'cpu' branch
#WORKDIR /home
#RUN git clone https://github.com/TradeMaster-NTU/TradeMaster.git && \
#    cd TradeMaster && \
#    git checkout cpu

COPY . /home/TradeMaster

# Set working directory to TradeMaster
WORKDIR /home/TradeMaster

# Install all dependencies in one go to reduce layers and optimize caching
# RUN conda run -n TradeMaster conda install -y \
#     pytorch torchvision torchaudio cpuonly -c pytorch -c conda-forge && \
#     conda run -n TradeMaster pip install --find-links https://pypi.org/simple gym==0.26.2 optuna ray[rllib]==2.44.0 && \
#     conda run -n TradeMaster pip install mmcv==2.2.0 && \
#     conda run -n TradeMaster pip install -r requirements.txt
# RUN conda run -n TradeMaster pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113 && \
#    conda run -n TradeMaster pip install -r requirements.txt

RUN conda run -n TradeMaster pip install "pip<24.1" "setuptools<60" "wheel<0.38"

RUN conda run -n TradeMaster pip install torch==1.12.1 torchvision==0.13.1 torchaudio==0.12.1
RUN conda run -n TradeMaster pip install gym==0.21.0
RUN conda run -n TradeMaster pip install ray[rllib]==1.13.0
RUN conda run -n TradeMaster pip install -r requirements.txt

# handle ray[rllib]==1.13.0 which requires gym==0.21.0 sepeartely. To install gym ==0.21.0. Need "pip<24.1" "setuptools<60" "wheel<0.38"


# Clean up unnecessary files to reduce the image size
RUN conda clean --all -y && \
    rm -rf /home/TradeMaster/.git

# Set default working directory
WORKDIR /home/TradeMaster