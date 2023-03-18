# sd-webui-docker

[![GitHub](https://img.shields.io/github/license/ebiiim/sd-webui-docker)](https://github.com/ebiiim/sd-webui-docker/blob/main/LICENSE)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/ebiiim/sd-webui-docker)](https://github.com/ebiiim/sd-webui-docker/releases/latest)
[![Release](https://github.com/ebiiim/sd-webui-docker/actions/workflows/release.yaml/badge.svg)](https://github.com/ebiiim/sd-webui-docker/actions/workflows/release.yaml)

Yet another Docker image for [stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) focuses on simplicity.

## Getting Started

1. Prepare your work directory
   ```sh
   # go to your work dir first
   mkdir -p ./models/Stable-diffusion ./outputs # create dirs
   echo '{}' | tee config.json ui-config.json # create empty configs
   ```
   ```
    .
    ├── models
    │   └── Stable-diffusion
    ├── outputs
    ├── config.json
    └── ui-config.json
   ```
1. Download models
   ```sh
   curl -L -o models/Stable-diffusion/v1-5-pruned-emaonly.safetensors https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors
   ```
   ```
   .
    ├── models
    │   └── Stable-diffusion
    │       └── v1-5-pruned-emaonly.safetensors
    ├── outputs
    ├── config.json
    └── ui-config.json
   ```
1. Run the server
   ```sh
   docker run --rm --gpus all -p 7860:7860 \
     -v "$(pwd)"/models:/work/stable-diffusion-webui/shared-models \
     -v "$(pwd)"/outputs:/work/stable-diffusion-webui/outputs \
     -v "$(pwd)"/config.json:/work/stable-diffusion-webui/config.json \
     -v "$(pwd)"/ui-config.json:/work/stable-diffusion-webui/ui-config.json \
     ghcr.io/ebiiim/sd-webui \
     --xformers --api \
     --ckpt-dir=shared-models/Stable-diffusion
   ```

## Usage

> 💡 Please read [stable-diffusion-webui CLI docs](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Command-Line-Arguments-and-Settings) before using this image.

Basically `docker run --rm --gpus all -p 7860:7860 <IMAGE> [ARGS]...`. The entrypoint is `launch.py --listen` so please pass additional arguments.

**Run on GPU servers**

Optionally pass `--xformers` `--api`.

```sh
docker run --rm --gpus all -p 7860:7860 ghcr.io/ebiiim/sd-webui --xformers --api
```

**CPU-only mode**

Pass `--use-cpu all`, and optionally pass `--api`.

```sh
docker run --rm --gpus all -p 7860:7860 ghcr.io/ebiiim/sd-webui --use-cpu all --api
```

**Sync outputs to local**

Use [Docker `-v` flag](https://docs.docker.com/storage/volumes/).

```sh
mkdir -p "$(pwd)"/outputs
docker run --rm --gpus all -p 7860:7860 \
  -v "$(pwd)"/outputs:/work/stable-diffusion-webui/outputs \
  ghcr.io/ebiiim/sd-webui \
  --xformers --api
```

**Use your own models**

Use `--ckpt-dir` and [Docker `-v` flag](https://docs.docker.com/storage/volumes/).

```sh
MODELS_DIR=/path/to/models
docker run --rm --gpus all -p 7860:7860 \
  -v "${MODELS_DIR}":/work/stable-diffusion-webui/shared-models \
  ghcr.io/ebiiim/sd-webui \
  --xformers --api \
  --ckpt-dir=shared-models/Stable-diffusion
```

**Sync configs to local**

Use [Docker `-v` flag](https://docs.docker.com/storage/volumes/).

```sh
echo '{}' | tee config.json ui-config.json
docker run --rm --gpus all -p 7860:7860 \
  -v "$(pwd)"/config.json:/work/stable-diffusion-webui/config.json \
  -v "$(pwd)"/ui-config.json:/work/stable-diffusion-webui/ui-config.json \
  ghcr.io/ebiiim/sd-webui \
  --xformers --api
```

## Acknowledgements

This work is based on projects whose licenses are listed below.

- AUTOMATIC1111/stable-diffusion-webui
  - https://github.com/AUTOMATIC1111/stable-diffusion-webui#credits
  - https://github.com/AUTOMATIC1111/stable-diffusion-webui/blob/master/LICENSE.txt
- NVIDIA Deep Learning Container
  - https://hub.docker.com/r/nvidia/cuda
  - https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license

## Changelog

### 1.0.0 - 2023-03-18

- initial release
- stable-diffusion-webui: [a9fed7c364061ae6efb37f797b6b522cb3cf7aa2](https://github.com/AUTOMATIC1111/stable-diffusion-webui/tree/a9fed7c364061ae6efb37f797b6b522cb3cf7aa2) 2023-03-14
