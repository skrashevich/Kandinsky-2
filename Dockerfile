# syntax=docker/dockerfile:1.2

ARG PIP_CACHE_DIR=/var/cache/buildkit/pip

FROM python:3.10 as wheels
ARG PIP_CACHE_DIR
ENV PIP_CACHE_DIR ${PIP_CACHE_DIR}
RUN mkdir -p ${PIP_CACHE_DIR}

RUN --mount=type=cache,target=${PIP_CACHE_DIR} python3 -mensurepip
RUN --mount=type=cache,target=${PIP_CACHE_DIR} pip3 wheel --wheel-dir=/wheels Pillow attrs torch filelock requests tqdm ftfy regex numpy blobfile 'transformers==4.23.1' \
    torchvision omegaconf pytorch_lightning einops sentencepiece opencv-python gradio 'git+https://github.com/openai/CLIP.git'

FROM python:3.10
ARG PIP_CACHE_DIR
ENV PIP_CACHE_DIR ${PIP_CACHE_DIR}
RUN mkdir -p ${PIP_CACHE_DIR}

WORKDIR /app
RUN apt update
RUN apt install -y --no-install-recommends libgl1
RUN --mount=type=cache,target=${PIP_CACHE_DIR} --mount=type=bind,from=wheels,source=/wheels,target=/wheels python3 -mpip install -U /wheels/*.whl
ADD . /app/
WORKDIR /app
RUN --mount=type=cache,target=${PIP_CACHE_DIR} python3 -mpip install .

RUN chmod +x /app/kandinsky2_gradio_app.py
CMD python3 /app/kandinsky2_gradio_app.py
