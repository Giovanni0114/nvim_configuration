ARG UBUNTU=22.04
FROM ubuntu:${UBUNTU}

ARG DEBIAN_FRONTEND=noninteractive
ARG NEOVIM_VERSION=stable

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates git locales \
    tar xz-utils unzip \
    python3 python3-venv python3-pip \
    nodejs npm \
    xxd wamerican \
    ripgrep fd-find jq \
    build-essential \
    && rm -rf /var/lib/apt/lists/*;

RUN locale-gen en_US.UTF-8;
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN set -eux; \
  cd /tmp; \
  case "$NEOVIM_VERSION" in \
    stable)  URL=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | jq -r '.assets[] | select(.name|test("nvim-linux-x86_64.tar.gz")) | .browser_download_url');; \
    nightly) URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz";; \
    v*)      URL="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux64.tar.gz";; \
    *) echo "Unsupported NEOVIM_VERSION: $NEOVIM_VERSION" && exit 1;; \
  esac; \
  curl -L "$URL" -o nvim.tar.gz; \
  tar xzf nvim.tar.gz; \
  mv nvim-linux-x86_64 /opt/nvim; \
  ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim; \
  nvim --version;

RUN mkdir -p /workspace/.ci-artifacts && chmod -R 777 /workspace/.ci-artifacts;

# non-root home and working dir
RUN useradd -m ci;
USER ci
WORKDIR /home/ci


ENV XDG_CONFIG_HOME=/home/ci/.config
ENV XDG_DATA_HOME=/home/ci/.local/share
ENV XDG_STATE_HOME=/home/ci/.local/state
ENV XDG_CACHE_HOME=/home/ci/.cache

USER root
COPY .ci/run_health.sh /ci/run_health.sh
RUN chmod +x /ci/run_health.sh;
USER ci
