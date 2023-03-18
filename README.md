# sd-webui-docker

[![GitHub](https://img.shields.io/github/license/ebiiim/sd-webui-docker)](https://github.com/ebiiim/sd-webui-docker/blob/main/LICENSE)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/ebiiim/sd-webui-docker)](https://github.com/ebiiim/sd-webui-docker/releases/latest)
[![Release](https://github.com/ebiiim/sd-webui-docker/actions/workflows/release.yaml/badge.svg)](https://github.com/ebiiim/sd-webui-docker/actions/workflows/release.yaml)

Yet another Docker image for [stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) focuses on simplicity.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [**Getting Started**](#getting-started)
  - [1. Prepare your work directory](#1-prepare-your-work-directory)
  - [2. Download models](#2-download-models)
  - [3. Start the server](#3-start-the-server)
- [**Usage**](#usage)
  - [Run on GPU servers](#run-on-gpu-servers)
  - [CPU-only mode](#cpu-only-mode)
  - [Sync outputs to local](#sync-outputs-to-local)
  - [Use your own models](#use-your-own-models)
  - [Sync configs to local](#sync-configs-to-local)
- [**Kubernetes**](#kubernetes)
  - [Architecture](#architecture)
  - [Deploy with Kustomize](#deploy-with-kustomize)
  - [Configure kustomization.yaml](#configure-kustomizationyaml)
    - [Enable Ingress](#enable-ingress)
    - [Use Waifu Diffusion](#use-waifu-diffusion)
- [**Acknowledgements**](#acknowledgements)
- [**Changelog**](#changelog)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## **Getting Started**

### 1. Prepare your work directory

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

### 2. Download models

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

### 3. Start the server

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

Then open http://localhost:7860 in your browser.

## **Usage**

> 💡 Please read [stable-diffusion-webui CLI docs](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Command-Line-Arguments-and-Settings) before using this image.

Basically `docker run --rm --gpus all -p 7860:7860 <IMAGE> [ARGS]...`. The entrypoint is `launch.py --listen` so please pass additional arguments.

### Run on GPU servers

Optionally pass `--xformers` `--api`.

```sh
docker run --rm --gpus all -p 7860:7860 ghcr.io/ebiiim/sd-webui --xformers --api
```

### CPU-only mode

Pass `--use-cpu all`, and optionally pass `--api`.

```sh
docker run --rm --gpus all -p 7860:7860 ghcr.io/ebiiim/sd-webui --use-cpu all --api
```

### Sync outputs to local

Use Docker `-v` flag.

```sh
mkdir -p "$(pwd)"/outputs
docker run --rm --gpus all -p 7860:7860 \
  -v "$(pwd)"/outputs:/work/stable-diffusion-webui/outputs \
  ghcr.io/ebiiim/sd-webui \
  --xformers --api
```

### Use your own models

Use `--ckpt-dir` and Docker `-v` flag.

```sh
MODELS_DIR=/path/to/models
docker run --rm --gpus all -p 7860:7860 \
  -v "${MODELS_DIR}":/work/stable-diffusion-webui/shared-models \
  ghcr.io/ebiiim/sd-webui \
  --xformers --api \
  --ckpt-dir=shared-models/Stable-diffusion
```

### Sync configs to local

Use Docker `-v` flag.

```sh
echo '{}' | tee config.json ui-config.json
docker run --rm --gpus all -p 7860:7860 \
  -v "$(pwd)"/config.json:/work/stable-diffusion-webui/config.json \
  -v "$(pwd)"/ui-config.json:/work/stable-diffusion-webui/ui-config.json \
  ghcr.io/ebiiim/sd-webui \
  --xformers --api
```

## **Kubernetes**

### Architecture
![components.png](docs/components.png)

### Deploy with Kustomize

> 💡 Please make sure GPUs are enabled on your cluster.

Create the namespace, 
```sh
kubectl create ns stable-diffusion-webui
```

apply manifests,

```sh
kubectl apply -k https://github.com/ebiiim/sd-webui-docker/k8s
```

forward the port to access,

```sh
kubectl port-forward -n stable-diffusion-webui svc/stable-diffusion-webui 7860:7860
```

and open http://localhost:7860 in your browser.

### Configure kustomization.yaml

Download `kustomization.yaml` and edit it.

```sh
curl -Lo https://raw.githubusercontent.com/ebiiim/sd-webui-docker/main/k8s/kustomization.yaml
```

#### Enable Ingress

Uncomment the resource,

```diff
 resources:
   # Ingress (optional)
-  # - https://raw.githubusercontent.com/ebiiim/sd-webui-docker/v1.1.0/k8s/bases/ing.yaml
+  - https://raw.githubusercontent.com/ebiiim/sd-webui-docker/v1.1.0/k8s/bases/ing.yaml
```

and set your domain name.

```diff
 patches:
   # [Ingress] To set ingressClassName and host name, uncomment the patch.
   - target:
       group: networking.k8s.io
       version: v1
       kind: Ingress
       name: stable-diffusion-webui
     patch: |-
       # - op: add
       #   path: /spec/ingressClassName
       #   value: nginx
-      # - op: replace
-      #   path: /spec/rules/0/host
-      #   value: stable-diffusion.localdomain
+      - op: replace
+        path: /spec/rules/0/host
+        value: [YOUR_DOMAIN_HERE]
```

#### Use Waifu Diffusion

Uncomment the resource.

```diff
  resources:
    # [MODELS] Please install 1 or more models.
    - ./models/install-sd15.yaml # Stable Diffusion 1.5
-   # - ./models/install-wd15b2.yaml # Waifu Diffusion 1.5 beta2
+   - ./models/install-wd15b2.yaml # Waifu Diffusion 1.5 beta2
```

## **Acknowledgements**

This work is based on projects whose licenses are listed below.

- AUTOMATIC1111/stable-diffusion-webui
  - https://github.com/AUTOMATIC1111/stable-diffusion-webui#credits
  - https://github.com/AUTOMATIC1111/stable-diffusion-webui/blob/master/LICENSE.txt
- NVIDIA Deep Learning Container
  - https://hub.docker.com/r/nvidia/cuda
  - https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license

## **Changelog**

**1.1.0 - 2023-03-??**

- Kubernetes support

**1.0.0 - 2023-03-18**

- initial release
- stable-diffusion-webui: [a9fed7c364061ae6efb37f797b6b522cb3cf7aa2](https://github.com/AUTOMATIC1111/stable-diffusion-webui/tree/a9fed7c364061ae6efb37f797b6b522cb3cf7aa2) 2023-03-14
