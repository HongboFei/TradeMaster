# Use NVIDIA CUDA 12.8.0 with cuDNN and Ubuntu 20.04
FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu20.04

# Install essential dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    ca-certificates \
    cmake \
    git \
    curl \
    libopenmpi-dev \
    python3-dev \
    zlib1g-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libgtk2.0-dev \
    swig && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN curl -o ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh 

# Set environment variables for Conda
ENV PATH /opt/conda/bin:$PATH
RUN conda update -n base -c defaults conda -y

# Create and activate TradeMaster environment
RUN conda create --name TradeMaster python=3.10 conda -y

# Ensure Conda is activated when using shell
SHELL ["/bin/bash", "-c"]
RUN echo "source activate TradeMaster" >> ~/.bashrc
RUN echo "conda activate TradeMaster" >> ~/.bashrc
ENV CONDA_DEFAULT_ENV TradeMaster
ENV PATH /opt/conda/envs/TradeMaster/bin:$PATH

# Clone TradeMaster repository
WORKDIR /home
RUN git clone https://github.com/TradeMaster-NTU/TradeMaster.git
WORKDIR /home/TradeMaster

# Install PyTorch with CUDA 12
RUN conda install -n TradeMaster -y \
    pytorch \
    torchvision \
    torchaudio \
    pytorch-cuda=12.1 -c pytorch -c nvidia

# Install NVIDIA Apex
WORKDIR /home
RUN git clone https://github.com/NVIDIA/apex
WORKDIR /home/apex
RUN pip install packaging
RUN pip install -v --no-cache-dir .

# Install TradeMaster dependencies
WORKDIR /home/TradeMaster
RUN pip install -r requirements.txt

# Set default working directory
WORKDIR /home/TradeMaster
