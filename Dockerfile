# Use NVIDIA CUDA 12.8.0 with cuDNN and Ubuntu 20.04
FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu20.04

# Install essential dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    ca-certificates cmake git curl libopenmpi-dev python3-dev zlib1g-dev \
    libgl1-mesa-glx libglib2.0-0 libgtk2.0-dev swig && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN curl -o ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh 

# Set environment variables for Conda
ENV PATH="/opt/conda/bin:$PATH"

# Create and activate Conda environment
RUN conda update -n base -c defaults conda -y && \
    conda create --prefix /opt/conda/envs/TradeMaster python=3.10 -y

# Use bash shell so conda activation works
SHELL ["/bin/bash", "-c"]

# Set Conda environment variables
ENV CONDA_DEFAULT_ENV=TradeMaster
ENV PATH="/opt/conda/envs/TradeMaster/bin:$PATH"

# Clone TradeMaster repository
WORKDIR /home
RUN git clone https://github.com/TradeMaster-NTU/TradeMaster.git
WORKDIR /home/TradeMaster

# Install PyTorch with CUDA 12
RUN conda run -n TradeMaster conda install -y \
    pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia

# Verify PyTorch Installation
RUN conda run -n TradeMaster python -c "import torch; print('Torch Version:', torch.__version__)"

# Install NVIDIA Apex
WORKDIR /home
RUN git clone https://github.com/NVIDIA/apex
WORKDIR /home/apex

# Install Apex with no build isolation
RUN conda run -n TradeMaster pip install packaging
RUN conda run -n TradeMaster pip install -v --no-cache-dir --no-build-isolation .

#install mmcv directly
RUN conda run -n TradeMaster pip install mmcv==2.2.0
RUN conda run -n TradeMaster python -c "import mmcv; print('mmcv Version:', mmcv.__version__)"

# Install gym 0.26.2
RUN conda run -n TradeMaster pip install --find-links https://pypi.org/simple gym==0.26.2
# Verify Gym Installation
RUN conda run -n TradeMaster python -c "import gym; print('Gym Version:', gym.__version__)"

#install optuna directly
RUN conda run -n TradeMaster pip install optuna
# Verify optuna installed
RUN conda run -n TradeMaster python -c "import optuna; print('optuna Version:', optuna.__version__)"

#install Ray directly
#RUN conda run -n TradeMaster pip install ray[rllib]
#RUN conda run -n TradeMaster pip install "sympy==1.13.1" "ray[rllib]==2.44.0"
RUN conda run -n TradeMaster pip install ray[rllib]==2.44.0
RUN conda run -n TradeMaster python -c "import ray; print('ray Version:', ray.__version__)"



# Install TradeMaster dependencies
WORKDIR /home/TradeMaster
RUN conda run -n TradeMaster pip install -r requirements.txt





# Set default working directory
WORKDIR /home/TradeMaster
