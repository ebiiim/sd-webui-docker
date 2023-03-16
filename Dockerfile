FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04


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
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

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

# preload
RUN curl -L -o models/Stable-diffusion/v1-5-pruned-emaonly.safetensors https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors
RUN python3 -mvenv venv
RUN /work/stable-diffusion-webui/venv/bin/pip install torch==1.13.1+cu117 -i https://download.pytorch.org/whl/cu117
RUN /work/stable-diffusion-webui/venv/bin/pip install xformers==0.0.16rc425

# setup
RUN /work/stable-diffusion-webui/venv/bin/python -c "from launch import *; prepare_environment()" --skip-torch-cuda-test


################################
# post setup
################################

EXPOSE 7860
ENTRYPOINT ["/work/stable-diffusion-webui/venv/bin/python", "webui.py", "--listen"]
