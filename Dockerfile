# ── dev-lab-image ────────────────────────────────────────────────────────
# Imagem do ambiente de desenvolvimento: code-server (linuxserver) com
# Python, Node.js LTS, git/gh e Docker CLI.
#
# Base fixada por tag + digest para builds reproduzíveis. O Dependabot
# (.github/dependabot.yml) propõe a atualização dos dois juntos.
FROM lscr.io/linuxserver/code-server:4.141.0-ls369@sha256:0d590a1a80a36bd2559222ad6e9f69559e962cca003f6f716b62487999d575f5

# Linha de release do Node.js instalada a partir do repositório da NodeSource.
# O apt do Ubuntu 24.04 só oferece o Node 18, que está sem suporte.
# ponytail: linha fixa em 24.x, trocar para 26.x quando ela virar LTS e o projeto precisar
ARG NODE_MAJOR=24

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates curl gnupg \
    python3 python3-pip python3-venv python3-dev \
    build-essential git gh wget \
    && install -m 0755 -d /etc/apt/keyrings \
    # ── Repositório Docker (somente CLI; o daemon é o do host via socket) ──
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
       -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && . /etc/os-release \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
       > /etc/apt/sources.list.d/docker.list \
    # ── Repositório NodeSource (chave + source manual, sem curl | bash) ──
    # Baixa para arquivo antes do dearmor: num pipe, uma falha do curl seria mascarada.
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
       -o /tmp/nodesource.key \
    && gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg /tmp/nodesource.key \
    && rm /tmp/nodesource.key \
    && chmod a+r /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
       > /etc/apt/sources.list.d/nodesource.list \
    # ── Pacotes dos repositórios externos (nodejs da NodeSource já inclui npm) ──
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
       nodejs docker-ce-cli docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*
