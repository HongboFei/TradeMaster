# Use NVIDIA CUDA base image with Ubuntu 20.04
FROM nvidia/cuda:11.3.0-cudnn8-devel-ubuntu20.04

# Install system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -y \
    ca-certificates cmake git curl libopenmpi-dev python3-dev zlib1g-dev \
    libgl1-mesa-glx libglib2.0-0 libgtk2.0-dev swig && \
    rm -rf /var/lib/apt/lists/*

# Install Anaconda and create Conda environment
RUN curl -o ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x ~/miniconda.sh && ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda create --name TradeMaster python=3.9 -y

# Set Conda environment as default shell
SHELL ["/bin/bash", "-c"]

# Ensure Conda environment is activated in each RUN command
ENV PATH="/opt/conda/bin:$PATH"
ENV CONDA_DEFAULT_ENV=TradeMaster
ENV CONDA_PREFIX=/opt/conda/envs/TradeMaster
ENV PATH="${CONDA_PREFIX}/bin:$PATH"

# Clone TradeMaster repository
RUN git clone https://github.com/TradeMaster-NTU/TradeMaster.git /home/TradeMaster

# Update Conda and ensure activation
RUN conda update -y conda

# Install PyTorch with CUDA 11.3
RUN conda run -n TradeMaster pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113

# Install Apex (with CUDA optimizations)
WORKDIR /home
RUN conda run -n TradeMaster pip install packaging
RUN git clone https://github.com/NVIDIA/apex && cd apex && \
    conda run -n TradeMaster pip install --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" .

# Install TradeMaster requirements
WORKDIR /home/TradeMaster
RUN conda run -n TradeMaster pip install -r requirements.txt
