FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04

LABEL maintainer "Shunsuke Ise <ise@ebiiim.com>"

################################
# init
################################

# install prerequisites
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    curl \
    git \
    git-lfs \
    python3.10 \
    python3.10-venv \
    python3-pip \
    libgl1 \
    libglib2.0-0
RUN apt-get clean -y && rm -rf /var/lib/apt/lists/*

# user and workdir
RUN useradd -m user
RUN mkdir /work && chown -R user:user /work
USER user
WORKDIR /work


################################
# setup
################################

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
WORKDIR /work/stable-diffusion-webui
# version: Mar 14, 2023
RUN git checkout a9fed7c364061ae6efb37f797b6b522cb3cf7aa2

# setup
RUN python3 -mvenv venv && /work/stable-diffusion-webui/venv/bin/python -c "from launch import *; prepare_environment()" --skip-torch-cuda-test --no-download-sd-model


################################
# entrypoint
################################

EXPOSE 7860
ENTRYPOINT ["/work/stable-diffusion-webui/venv/bin/python", "launch.py", "--listen"]
