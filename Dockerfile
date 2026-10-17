
FROM lscr.io/linuxserver/code-server:latest

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      python3 \
      python3-pip \
      python3-venv \
      python3-dev \
      build-essential \
      curl \
      wget \
      git \
      nodejs \
      npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
