ARG VERSION $VERSION

FROM ubuntu:24.04

# Set shell options for better error handling
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

LABEL maintainer="Tom Atwood<tom@tmatwood.com>"
LABEL org.opencontainers.image.version=24.04
LABEL org.opencontainers.image.ref.name=ubuntu


#  ██  ██      ███████ ███    ██ ██    ██     ██    ██  █████  ██████  ██  █████  ██████  ██      ███████ ███████
# ████████     ██      ████   ██ ██    ██     ██    ██ ██   ██ ██   ██ ██ ██   ██ ██   ██ ██      ██      ██
#  ██  ██      █████   ██ ██  ██ ██    ██     ██    ██ ███████ ██████  ██ ███████ ██████  ██      █████   ███████
# ████████     ██      ██  ██ ██  ██  ██       ██  ██  ██   ██ ██   ██ ██ ██   ██ ██   ██ ██      ██           ██
#  ██  ██      ███████ ██   ████   ████         ████   ██   ██ ██   ██ ██ ██   ██ ██████  ███████ ███████ ███████

ARG APT_KEY_DONT_WARN_IN_DANGEROUS_USAGE=1
ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C
ENV GROUP=dev
ENV NON_INTERACTIVE=1
ENV USER=dev
ENV version=$VERSION


#  ██  ██      ███████  ██████  ██    ██ ███    ██ ██████   █████  ████████ ██  ██████  ███    ██ ███████
# ████████     ██      ██    ██ ██    ██ ████   ██ ██   ██ ██   ██    ██    ██ ██    ██ ████   ██ ██
#  ██  ██      █████   ██    ██ ██    ██ ██ ██  ██ ██   ██ ███████    ██    ██ ██    ██ ██ ██  ██ ███████
# ████████     ██      ██    ██ ██    ██ ██  ██ ██ ██   ██ ██   ██    ██    ██ ██    ██ ██  ██ ██      ██
#  ██  ██      ██       ██████   ██████  ██   ████ ██████  ██   ██    ██    ██  ██████  ██   ████ ███████

WORKDIR /home/root
USER root

# Preliminary foundation packages installed first
RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends \
      adduser \
      apt-transport-https \
      apt-utils \
      axel \
      bash \
      bash-completion \
      bsdmainutils \
      build-essential \
      ca-certificates \
      cargo \
      curl \
      dbus-user-session \
      dkms \
      dpkg \
      fuse-overlayfs \
      git \
      gnupg \
      gnupg2 \
      iptables \
      jq \
      libffi-dev \
      libpam-systemd \
      libplist-utils \
      libssl-dev \
      libxi-dev \
      libxmu-dev \
      lsb-release \
      make \
      slirp4netns \
      software-properties-common \
      systemd \
      systemd-container \
      systemd-cron \
      systemd-resolved \
      systemd-sysv \
      sudo \
      tzdata \
      ubuntu-keyring \
      ubuntu-wsl \
      uidmap \
      unzip \
      wsl-setup \
      wget \
      wslu \
      zip \
    && dpkg-reconfigure ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*


#  ██  ██       ██████ ██████  ███████  █████  ████████ ███████     ██    ██ ███████ ███████ ██████  ███████
# ████████     ██      ██   ██ ██      ██   ██    ██    ██          ██    ██ ██      ██      ██   ██ ██
#  ██  ██      ██      ██████  █████   ███████    ██    █████       ██    ██ ███████ █████   ██████  ███████
# ████████     ██      ██   ██ ██      ██   ██    ██    ██          ██    ██      ██ ██      ██   ██      ██
#  ██  ██       ██████ ██   ██ ███████ ██   ██    ██    ███████      ██████  ███████ ███████ ██   ██ ███████

# Create dev user with explicit UID/GID and sudo access
RUN groupadd -g 1001 ${USER} \
    && groupadd -r docker \
    && groupadd -r linuxbrew \
    && useradd -m -u 1001 -g 1001 -s /bin/bash ${USER} \
    && usermod -aG sudo ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-${USER}-nopasswd \
    && chmod 0440 /etc/sudoers.d/90-${USER}-nopasswd \
    && adduser ${USER} adm \
    && useradd --create-home -g linuxbrew -s /bin/bash linuxbrew \
    && echo "linuxbrew ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && usermod -aG docker ${USER} \
    && mkdir -p /home/linuxbrew/.linuxbrew \
    && chown -R linuxbrew:linuxbrew /home/linuxbrew/.linuxbrew


#  ██  ██       █████  ██████  ██████      ██████  ███████ ██████   ██████  ███████
# ████████     ██   ██ ██   ██ ██   ██     ██   ██ ██      ██   ██ ██    ██ ██
#  ██  ██      ███████ ██   ██ ██   ██     ██████  █████   ██████  ██    ██ ███████
# ████████     ██   ██ ██   ██ ██   ██     ██   ██ ██      ██      ██    ██      ██
#  ██  ██      ██   ██ ██████  ██████      ██   ██ ███████ ██       ██████  ███████

RUN add-apt-repository ppa:kubescape/kubescape \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && add-apt-repository ppa:cappelikan/ppa -y \
    && add-apt-repository ppa:dotnet/backports -y \
    && apt-get -y update \
    && rm -rf /var/lib/apt/lists/*

# RUN wget -O - https://apt.corretto.aws/corretto.key | sudo gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg \
#     && echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | sudo tee /etc/apt/sources.list.d/corretto.list

RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/keyrings/hashicorp-archive-keyring.gpg \
    && chmod 644 /etc/apt/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get clean \
    && apt-get update -y \
    && rm -rf /var/lib/apt/lists/*

RUN (apt-get remove -y 'dotnet*' 'aspnet*' 'netstandard*' || true) \
    && echo "Package: dotnet* aspnet* netstandard*" > /etc/apt/preferences \
    && echo "Pin: origin \"packages.microsoft.com\"" >> /etc/apt/preferences \
    && echo "Pin-Priority: -10" >> /etc/apt/preferences \
    && . /etc/os-release \
    && wget -q https://packages.microsoft.com/config/"$ID"/"$VERSION_ID"/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && rm -rf /var/lib/apt/lists/*


#  ██  ██      ██     ██ ███████ ██           ██████  ██████  ███    ██ ███████ ██  ██████
# ████████     ██     ██ ██      ██          ██      ██    ██ ████   ██ ██      ██ ██
#  ██  ██      ██  █  ██ ███████ ██          ██      ██    ██ ██ ██  ██ █████   ██ ██   ███
# ████████     ██ ███ ██      ██ ██          ██      ██    ██ ██  ██ ██ ██      ██ ██    ██
#  ██  ██       ███ ███  ███████ ███████      ██████  ██████  ██   ████ ██      ██  ██████

# See https://learn.microsoft.com/en-us/windows/wsl/wsl-config
# WSL config: enable systemd, set default user, configure automount and network
RUN tee /etc/wsl.conf >/dev/null <<'EOF'
[boot]
systemd=true

[user]
default=dev

[automount]
enabled=true
options=metadata,umask=22,fmask=11
mountFsTab=false

[network]
generateResolvConf=true

[interop]
appendWindowsPath=true
EOF

# Create custom resolv.conf override for DNS
RUN echo "nameserver 1.1.1.1" > /etc/resolv.conf.override \
    && echo "nameserver 8.8.4.4" >> /etc/resolv.conf.override \
    && echo "nameserver 8.8.8.8" >> /etc/resolv.conf.override

# Create symlinks to Windows tools (will work when WSL is running)
RUN ln -s '/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe' /usr/bin/git-credential-manager || true \
    && ln -s '/mnt/c/Program Files/Microsoft VS Code/code.exe' /usr/bin/code || true


#  ██  ██       ██████  ██ ████████      ██████  ██████  ███    ██ ███████ ██  ██████
# ████████     ██       ██    ██        ██      ██    ██ ████   ██ ██      ██ ██
#  ██  ██      ██   ███ ██    ██        ██      ██    ██ ██ ██  ██ █████   ██ ██   ███
# ████████     ██    ██ ██    ██        ██      ██    ██ ██  ██ ██ ██      ██ ██    ██
#  ██  ██       ██████  ██    ██         ██████  ██████  ██   ████ ██      ██  ██████

WORKDIR /home/${USER}
USER ${USER}

# Git config
RUN git config --global core.autocrlf false \
    && git config --global core.ignorecase false \
    && git config --global credential.helper store \
    && git config --global credential.https://github.com.provider github \
    && git config --global init.defaultBranch main \
    && git config --global filter.lfs.clean 'git-lfs clean -- %f' \
    && git config --global filter.lfs.process 'git-lfs filter-process' \
    && git config --global filter.lfs.required true \
    && git config --global filter.lfs.smudge 'git-lfs smudge -- %f' \
    && git config --global http.sslVerify true \
    && git config --global safe.directory /home/linuxbrew/.linuxbrew

WORKDIR /home/linuxbrew
USER linuxbrew

# Git config
RUN git config --global core.autocrlf false \
    && git config --global core.ignorecase false \
    && git config --global credential.helper store \
    && git config --global credential.https://github.com.provider github \
    && git config --global init.defaultBranch main \
    && git config --global filter.lfs.clean 'git-lfs clean -- %f' \
    && git config --global filter.lfs.process 'git-lfs filter-process' \
    && git config --global filter.lfs.required true \
    && git config --global filter.lfs.smudge 'git-lfs smudge -- %f' \
    && git config --global http.sslVerify true \
    && git config --global safe.directory /home/linuxbrew/.linuxbrew

WORKDIR /home/root
USER root

# Git config
RUN git config --global core.autocrlf false \
    && git config --global core.ignorecase false \
    && git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe" \
    && git config --global credential.https://github.com.provider github \
    && git config --global init.defaultBranch main \
    && git config --global filter.lfs.clean 'git-lfs clean -- %f' \
    && git config --global filter.lfs.process 'git-lfs filter-process' \
    && git config --global filter.lfs.required true \
    && git config --global filter.lfs.smudge 'git-lfs smudge -- %f' \
    && git config --global http.sslVerify true \
    && git config --global safe.directory /home/linuxbrew/.linuxbrew


#  ██  ██      ██████  ██████  ███████ ██     ██
# ████████     ██   ██ ██   ██ ██      ██     ██
#  ██  ██      ██████  ██████  █████   ██  █  ██
# ████████     ██   ██ ██   ██ ██      ██ ███ ██
#  ██  ██      ██████  ██   ██ ███████  ███ ███

WORKDIR /home/linuxbrew
USER linuxbrew

ENV PATH="${PATH}:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin"

RUN git clone https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew \
    && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && brew --version \
    && brew doctor \
    && brew upgrade

# Fix ownership as root
USER root
RUN chown -R linuxbrew:linuxbrew /home/linuxbrew/.linuxbrew

# Create /usr/local directories with proper permissions for Homebrew
# Note: We do NOT create a brew symlink in /usr/local/bin to avoid HOMEBREW_PREFIX conflicts
RUN mkdir -p /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/sbin /usr/local/share /usr/local/share/man /usr/local/share/man/man1 /usr/local/var /usr/local/Cellar /usr/local/Caskroom /usr/local/Frameworks /usr/local/opt \
    && chown -R ${USER}:${GROUP} /usr/local \
    && chmod -R u+w /usr/local


#  ██  ██      ███    ██ ██    ██ ███    ███
# ████████     ████   ██ ██    ██ ████  ████
#  ██  ██      ██ ██  ██ ██    ██ ██ ████ ██
# ████████     ██  ██ ██  ██  ██  ██  ██  ██
#  ██  ██      ██   ████   ████   ██      ██

WORKDIR /home/${USER}
USER ${USER}

RUN mkdir -p /home/${USER}/.nvm \
    && chown ${USER}:${GROUP} -R /home/${USER}/.nvm

ENV PATH="${PATH}:/home/${USER}/.nvm/bin"

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash \
    && export NVM_DIR="/home/${USER}/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
    && echo 'export NVM_DIR="/home/${USER}/.nvm"' >> /home/${USER}/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/${USER}/.bashrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /home/${USER}/.bashrc \
    && echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/${USER}/.bashrc \
    && nvm install node \
    && nvm use node \
    && node -v \
    && npm -v \
    && npm install -g @anthropic-ai/claude-code npm@latest dep-check npm-check newman snyk


#  ██  ██      ██████  ██    ██ ████████ ██   ██  ██████  ███    ██
# ████████     ██   ██  ██  ██     ██    ██   ██ ██    ██ ████   ██
#  ██  ██      ██████    ████      ██    ███████ ██    ██ ██ ██  ██
# ████████     ██         ██       ██    ██   ██ ██    ██ ██  ██ ██
#  ██  ██      ██         ██       ██    ██   ██  ██████  ██   ████

WORKDIR /home/root
USER root

ENV PATH="/home/${USER}/.local/bin:${PATH}"

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
      libbz2-dev \
      libffi-dev \
      libgdbm-dev \
      liblzma-dev \
      libncurses5-dev \
      libnss3-dev \
      libreadline-dev \
      libsqlite3-dev \
      libssl-dev \
      tk-dev \
      uuid-dev \
      wget \
      zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
      python3.11-full \
      python3.12-full \
      python3.13-full \
      python3.14-full \
      python3-pip \
      python3.11-venv \
      python3.12-venv \
      python3.13-venv \
      python3.14-venv \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get install -y --no-install-recommends \
    && python3.14 --version \
    && python3.13 --version \
    && python3.12 --version \
    && python3.11 --version \
    && which python3.14 \
    && which python3.13 \
    && which python3.12 \
    && which python3.11 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get -y update \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.11 3 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.12 2 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.13 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.14 1 \
    && update-alternatives --set python /usr/bin/python3.14 \
    && printf '#!/bin/bash\nupdate-alternatives --set python "/usr/bin/python3.11"\n' > /usr/bin/set-python-11.sh \
    && printf '#!/bin/bash\nupdate-alternatives --set python "/usr/bin/python3.12"\n' > /usr/bin/set-python-12.sh \
    && printf '#!/bin/bash\nupdate-alternatives --set python "/usr/bin/python3.13"\n' > /usr/bin/set-python-13.sh \
    && printf '#!/bin/bash\nupdate-alternatives --set python "/usr/bin/python3.14"\n' > /usr/bin/set-python-14.sh \
    && chmod +x /usr/bin/set-python-11.sh \
    && chmod +x /usr/bin/set-python-12.sh \
    && chmod +x /usr/bin/set-python-13.sh \
    && chmod +x /usr/bin/set-python-14.sh \
    && python --version \
    && rm -rf /var/lib/apt/lists/*


#  ██  ██       ██████ ██       █████  ███    ███  █████  ██    ██
# ████████     ██      ██      ██   ██ ████  ████ ██   ██ ██    ██
#  ██  ██      ██      ██      ███████ ██ ████ ██ ███████ ██    ██
# ████████     ██      ██      ██   ██ ██  ██  ██ ██   ██  ██  ██
#  ██  ██       ██████ ███████ ██   ██ ██      ██ ██   ██   ████

# ClamAV configuration after clamav and clamav-daemon are installed
# see https://https://aaronbrighton.medium.com/installation-configuration-of-clamav-antivirus-on-ubuntu-18-04-a6416bab3b41
RUN apt-get update \
    && apt-get install -y --no-install-recommends clamav clamav-daemon \
    && echo "0 1 * * 0 root /usr/bin/clamdscan --fdpass --log /var/log/clamav/clamav.log --move=/root/quartine /" | tee /etc/cron.d/clamav-scan \
    && printf "ExcludePath ^/proc\nExcludePath ^/sys\nExcludePath ^/snap\nExcludePath ^/dev\nExcludePath ^/run\nExcludePath ^/var/lib/lxcfs/cgroup\nExcludePath ^/root/quarantine\nExcludePath ^/var/lib/docker\n" >> /etc/clamav/clamd.conf \
    && echo "fs.inotify.max_user_watches = 524288" >> /etc/sysctl.conf \
    && mkdir -p /var/clamav/tmp \
    && chown clamav:root /var/clamav/tmp \
    && chmod 770 /var/clamav/tmp \
    && echo "# /etc/systemd/system/clamonacc.service" >> /etc/systemd/system/clamonacc.service \
    && echo "[Unit]" >> /etc/systemd/system/clamonacc.service \
    && echo "Description=ClamAV On Access Scanner" >> /etc/systemd/system/clamonacc.service \
    && echo "Requires=clamav-daemon.service" >> /etc/systemd/system/clamonacc.service \
    && echo "After=clamav-daemon.service syslog.target network.target" >> /etc/systemd/system/clamonacc.service \
    && echo "" >> /etc/systemd/system/clamonacc.service \
    && echo "[Service]" >> /etc/systemd/system/clamonacc.service \
    && echo "Type=simple" >> /etc/systemd/system/clamonacc.service \
    && echo "User=root" >> /etc/systemd/system/clamonacc.service \
    && echo "ExecStartPre=/bin/bash -c \"while [ ! -S /var/run/clamav/clamd.ctl ]; do sleep 1; done\"" >> /etc/systemd/system/clamonacc.service \
    && echo "ExecStart=/usr/bin/clamonacc -F --config-file=/etc/clamav/clamd.conf --log=/var/log/clamav/clamonacc.log --move=/root/quarantine" >> /etc/systemd/system/clamonacc.service \
    && echo "" >> /etc/systemd/system/clamonacc.service \
    && echo "[Install]" >> /etc/systemd/system/clamonacc.service \
    && echo "WantedBy=multi-user.target" >> /etc/systemd/system/clamonacc.service \
    && rm -rf /var/lib/apt/lists/*


#  ██  ██       ██████   ██████  ██████  ██████  ███████ ██     ██
# ████████     ██       ██    ██ ██   ██ ██   ██ ██      ██     ██
#  ██  ██      ██   ███ ██    ██ ██████  ██████  █████   ██  █  ██
# ████████     ██    ██ ██    ██ ██   ██ ██   ██ ██      ██ ███ ██
#  ██  ██       ██████   ██████  ██████  ██   ██ ███████  ███ ███

WORKDIR /home/${USER}
USER ${USER}

ENV PATH="/home/${USER}/.gobrew/current/bin:/home/${USER}/.gobrew/bin:/home/${USER}/go/bin:/home/${USER}/go/pkg:$PATH"

RUN curl -sLk https://git.io/gobrew | bash  # Install gobrew

RUN .gobrew/bin/gobrew use latest \
    && .gobrew/bin/gobrew install latest \
    && go install github.com/codesenberg/bombardier@latest


#  ██  ██      ███    ██ ██    ██  ██████  ███████ ████████     ██████  ██████  ███████ ██████
# ████████     ████   ██ ██    ██ ██       ██         ██        ██   ██ ██   ██ ██      ██   ██
#  ██  ██      ██ ██  ██ ██    ██ ██   ███ █████      ██        ██████  ██████  █████   ██████
# ████████     ██  ██ ██ ██    ██ ██    ██ ██         ██        ██      ██   ██ ██      ██
#  ██  ██      ██   ████  ██████   ██████  ███████    ██        ██      ██   ██ ███████ ██

WORKDIR /home/root
USER root

# Prep for NuGet (.NET)
RUN mkdir -p /home/${USER}/.nuget

COPY NuGet.Config /home/${USER}/.nuget/NuGet/NuGet.Config
COPY NuGet.Config /home/root/.nuget/NuGet/NuGet.Config


#  ██  ██       █████  ██████  ████████        ██████  ███████ ████████     ██████
# ████████     ██   ██ ██   ██    ██          ██       ██         ██             ██
#  ██  ██      ███████ ██████     ██    █████ ██   ███ █████      ██         █████
# ████████     ██   ██ ██         ██          ██    ██ ██         ██        ██
#  ██  ██      ██   ██ ██         ██           ██████  ███████    ██        ███████

WORKDIR /home/root
USER root

# Added as a workaround for the issue with the latest version of the Azure CLI
RUN sh -c 'echo "deb http://archive.ubuntu.com/ubuntu jammy main universe" > /etc/apt/sources.list.d/jammy.list' \
    && curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends \
        apparmor-utils \
        azure-cli \
        blobfuse2 \
        buildah \
        bzip2 \
        cifs-utils \
        cmake \
        consul \
        daemonize \
        dbus \
        dbus-x11 \
        dnsutils \
        dotnet-sdk-8.0 \
        dotnet-sdk-9.0 \
        entr \
        extlinux \
        ffmpeg \
        file \
        firefox \
        g++ \
        gawk \
        gcc \
        gimp \
        git-flow \
        git-lfs \
        htop \
        imagemagick \
        intltool \
        iproute2 \
        iptables \
        iputils-ping \
        kubescape \
        less \
        libc6 \
        libgcc-s1 \
        libicu74 \
        liblttng-ust1t64 \
        libpulse0 \
        libssl3t64 \
        libstdc++6 \
        libunwind8 \
        maven \
        nano \
        ncdu \
        net-tools \
        nuget \
        nvidia-cuda-toolkit \
        nvidia-cuda-toolkit-gcc \
        p7zip-full \
        packer \
        pkg-config \
        podman-docker \
        policykit-1 \
        powershell \
        protobuf-compiler \
        rsync \
        shellcheck\
        snapd \
        socat \
        ssh \
        sudo \
        synaptic \
        tasksel \
        tmux \
        uuid-runtime \
        vault \
        vlc \
        x11-apps \
        yamllint \
        zlib1g \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*


#  ██  ██           ██  █████  ██    ██  █████
# ████████          ██ ██   ██ ██    ██ ██   ██
#  ██  ██           ██ ███████ ██    ██ ███████
# ████████     ██   ██ ██   ██  ██  ██  ██   ██
#  ██  ██       █████  ██   ██   ████   ██   ██

WORKDIR /home/root
USER root

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        openjdk-8-jdk \
        openjdk-11-jdk \
        openjdk-17-jdk \
        openjdk-21-jdk \
    && update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-openjdk-amd64/bin/java 1 \
    && update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-11-openjdk-amd64/bin/java 2 \
    && update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-openjdk-amd64/bin/java 3 \
    && update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-21-openjdk-amd64/bin/java 4 \
    && update-alternatives --set java "/usr/lib/jvm/java-21-openjdk-amd64/bin/java" \
    && printf '#!/bin/bash\nupdate-alternatives --set java "/usr/lib/jvm/java-8-openjdk-amd64/bin/java"\n' > /usr/bin/set-java-8.sh \
    && printf '#!/bin/bash\nupdate-alternatives --set java "/usr/lib/jvm/java-11-openjdk-amd64/bin/java"\n' > /usr/bin/set-java-11.sh \
    && printf '#!/bin/bash\nupdate-alternatives --set java "/usr/lib/jvm/java-17-openjdk-amd64/bin/java"\n' > /usr/bin/set-java-17.sh \
    && printf '#!/bin/bash\nupdate-alternatives --set java "/usr/lib/jvm/java-21-openjdk-amd64/bin/java"\n' > /usr/bin/set-java-21.sh \
    && chmod +x /usr/bin/set-java-8.sh \
    && chmod +x /usr/bin/set-java-11.sh \
    && chmod +x /usr/bin/set-java-17.sh \
    && chmod +x /usr/bin/set-java-21.sh \
    && rm -rf /var/lib/apt/lists/*


#  ██  ██         ███    ██ ███████ ████████     ████████  ██████   ██████  ██      ███████
# ████████        ████   ██ ██         ██           ██    ██    ██ ██    ██ ██      ██
#  ██  ██         ██ ██  ██ █████      ██           ██    ██    ██ ██    ██ ██      ███████
# ████████        ██  ██ ██ ██         ██           ██    ██    ██ ██    ██ ██           ██
#  ██  ██      ██ ██   ████ ███████    ██           ██     ██████   ██████  ███████ ███████

WORKDIR /home/${USER}
USER ${USER}

ENV PATH="/home/${USER}/.dotnet/tools:$PATH"

RUN dotnet tool install -g coverlet.console \
    && dotnet tool install -g CycloneDX \
    && dotnet tool install -g dotnet-coverage \
    && dotnet tool install -g dotnet-dump \
    && dotnet tool install -g dotnet-format\
    && dotnet tool install -g dotnet-gcdump \
    && dotnet tool install -g dotnet-reportgenerator-globaltool \
    && dotnet tool install -g dotnet-script \
    && dotnet tool install -g dotnet-trace \
    && dotnet tool install -g fake-cli \
    && dotnet tool install -g GitVersion.Tool \
    && dotnet tool install -g Microsoft.dotnet-interactive \
    && dotnet tool install -g paket \
    && dotnet tool install -g powershell \
    && dotnet tool install -g SpecFlow.Plus.LivingDoc.CLI \
    && dotnet tool install -g trx2junit


#  ██  ██       █████  ██      ██  █████  ███████ ███████ ███████
# ████████     ██   ██ ██      ██ ██   ██ ██      ██      ██
#  ██  ██      ███████ ██      ██ ███████ ███████ █████   ███████
# ████████     ██   ██ ██      ██ ██   ██      ██ ██           ██
#  ██  ██      ██   ██ ███████ ██ ██   ██ ███████ ███████ ███████

WORKDIR /home/root
USER root

RUN echo 'alias d="docker"\n' >> /home/${USER}/.bashrc \
    && echo 'alias dc="docker-compose"\n' >> /home/${USER}/.bashrc \
    && echo 'alias k="kubectl"' >> /home/${USER}/.bashrc \
    && echo 'alias p="podman"' >> /home/${USER}/.bashrc \
    && echo 'alias pc="podman compose"' >> /home/${USER}/.bashrc \
    && echo 'alias podman-compose="podman compose"' >> /home/${USER}/.bashrc \
    && echo 'alias tf="tofu"\n' >> /home/${USER}/.bashrc \
    && echo 'eval $(ssh-agent)' >> /home/${USER}/.bashrc \
    && echo 'export BROWSER=wslview' >> /home/${USER}/.bashrc


#  ██  ██      ██████  ██████  ███████ ██     ██     ██████
# ████████     ██   ██ ██   ██ ██      ██     ██          ██
#  ██  ██      ██████  ██████  █████   ██  █  ██      █████
# ████████     ██   ██ ██   ██ ██      ██ ███ ██     ██
#  ██  ██      ██████  ██   ██ ███████  ███ ███      ███████

WORKDIR /home/root
USER root

RUN chown -R ${USER}:${GROUP} /home/linuxbrew \
    && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && test -d /home/linuxbrew/.linuxbrew

WORKDIR /home/${USER}
USER ${USER}

ARG BUILD_DATE $BUILD_DATE

# Add Homebrew taps
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && brew tap spring-io/tap \
    && brew tap tofuutils/tap

# Install development tools
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && brew install act \
    && brew install bash-git-prompt \
    && brew install btop \
    && brew install gcc \
    && brew install gh \
    && brew install gitversion \
    && brew install tldr

# Install container tools
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && brew install container-structure-test \
    && brew install copa \
    && brew install cosign \
    && brew install crane \
    && brew install dive \
    && brew install hadolint \
    && brew install helm \
    && brew install k9s \
    && brew install kompose \
    && brew install krew \
    && brew install kubescape \
    && brew install kustomize \
    && brew install lazydocker \
    && brew install mkcert \
    && brew install podman

# Install security scanning tools
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && brew install dependency-check \
    && brew install grype \
    && brew install osv-scanner \
    && brew install syft \
    && brew install trivy

# Install infrastructure/terraform tools
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && brew install infracost \
    && brew install tenv \
    && brew install terraform-docs \
    && brew install terraformer \
    && brew install terrascan \
    && brew install tflint \
    && brew install tfsec \
    && brew install tfupdate

# Install specialized tools
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && brew install linka-cloud/tap/d2vm \
    && brew install spring-boot \
    && brew install uv \
    && brew install yamllint \
    && brew install yq

# Upgrade all brew packages and configure tenv
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && brew upgrade \
    && tenv opentofu install latest \
    && tenv opentofu use latest


#  ██  ██      ███████ ██      ██    ██ ██     ██  █████  ██    ██
# ████████     ██      ██       ██  ██  ██     ██ ██   ██  ██  ██
#  ██  ██      █████   ██        ████   ██  █  ██ ███████   ████
# ████████     ██      ██         ██    ██ ███ ██ ██   ██    ██
#  ██  ██      ██      ███████    ██     ███ ███  ██   ██    ██

WORKDIR /home/${USER}
USER ${USER}

# Install Flyway
RUN FLYWAY_REPO="https://github.com/flyway/flyway" \
    && LATEST_VERSION=$(curl -s https://api.github.com/repos/flyway/flyway/releases/latest | jq -r '.tag_name') \
    && export LATEST_VERSION \
    && FLYWAY_VERSION=${LATEST_VERSION##*-} \
    && echo "Flyway version is $FLYWAY_VERSION." \
    && wget -q --progress=dot:giga "https://github.com/flyway/flyway/releases/download/flyway-${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}-linux-x64.tar.gz" -O flyway.tar.gz \
    && file flyway.tar.gz \
    && tar -xvzf flyway.tar.gz \
    && rm flyway.tar.gz

# Create symlink as root
USER root
RUN ln -s "/home/${USER}/flyway-$(curl -s https://api.github.com/repos/flyway/flyway/releases/latest | jq -r '.tag_name' | sed 's/flyway-//')/flyway" /usr/local/bin/flyway \
    && flyway -v

USER ${USER}

#  ██  ██      ██      ██  ██████  ██    ██ ██ ██████   █████  ███████ ███████
# ████████     ██      ██ ██    ██ ██    ██ ██ ██   ██ ██   ██ ██      ██
#  ██  ██      ██      ██ ██    ██ ██    ██ ██ ██████  ███████ ███████ █████
# ████████     ██      ██ ██ ▄▄ ██ ██    ██ ██ ██   ██ ██   ██      ██ ██
#  ██  ██      ███████ ██  ██████   ██████  ██ ██████  ██   ██ ███████ ███████
#                             ▀▀

# Install Liquibase
RUN LIQUIBASE_REPO="https://github.com/liquibase/liquibase" \
    && LATEST_VERSION=$(curl -s https://api.github.com/repos/liquibase/liquibase/releases/latest | jq -r '.tag_name') \
    && export LATEST_VERSION \
    && LIQUIBASE_VERSION=${LATEST_VERSION#v} \
    && echo "Liquibase version is $LIQUIBASE_VERSION." \
    && wget -q --progress=dot:giga "https://github.com/liquibase/liquibase/releases/download/v${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}.tar.gz" -O liquibase.tar.gz \
    && file liquibase.tar.gz \
    && mkdir -p liquibase \
    && tar -xzf liquibase.tar.gz -C liquibase \
    && chmod +x liquibase/liquibase \
    && rm liquibase.tar.gz

# Create symlink as root
USER root
RUN ln -s "/home/${USER}/liquibase/liquibase" /usr/local/bin/liquibase \
    && liquibase --version

USER ${USER}


#  ██  ██       ██████  ██████  ██████  ███████  ██████  ██
# ████████     ██      ██    ██ ██   ██ ██      ██    ██ ██
#  ██  ██      ██      ██    ██ ██   ██ █████   ██    ██ ██
# ████████     ██      ██    ██ ██   ██ ██      ██ ▄▄ ██ ██
#  ██  ██       ██████  ██████  ██████  ███████  ██████  ███████
#                                                  ▀▀

USER root
WORKDIR /home/root

RUN CODEQL_REPO="https://github.com/github/codeql-action" \
    && DOWNLOAD_DIR="/home/${USER}" \
    && LATEST_VERSION=$(curl -sL https://api.github.com/repos/github/codeql-action/releases/latest | jq -r '.tag_name') \
    && export LATEST_VERSION \
    && CODEQL_VERSION=${LATEST_VERSION##*-} \
    && echo "CodeQL version is $CODEQL_VERSION." \
    && curl -sL "https://github.com/github/codeql-action/releases/download/codeql-bundle-${CODEQL_VERSION}/codeql-bundle-linux64.tar.gz" -o codeql-bundle-linux64.tar.gz \
    && tar -xvf codeql-bundle-linux64.tar.gz \
    && mv codeql /usr/local/bin/codeql \
    && ln -s /usr/local/bin/codeql/codeql /usr/bin/codeql \
    && rm codeql-bundle-linux64.tar.gz \
    && codeql --version


#  ██  ██      ██    ██ ███████ ███████ ██████   ██████   ██  ██████   ██████   ██    ███████ ███████ ██████  ██    ██ ██  ██████ ███████
# ████████     ██    ██ ██      ██      ██   ██ ██    ██ ███ ██  ████ ██  ████ ███    ██      ██      ██   ██ ██    ██ ██ ██      ██
#  ██  ██      ██    ██ ███████ █████   ██████  ██ ██ ██  ██ ██ ██ ██ ██ ██ ██  ██    ███████ █████   ██████  ██    ██ ██ ██      █████
# ████████     ██    ██      ██ ██      ██   ██ ██ ██ ██  ██ ████  ██ ████  ██  ██         ██ ██      ██   ██  ██  ██  ██ ██      ██
#  ██  ██       ██████  ███████ ███████ ██   ██  █ ████   ██  ██████   ██████   ██ ██ ███████ ███████ ██   ██   ████   ██  ██████ ███████

USER root
WORKDIR /home/root

RUN mkdir -p /etc/systemd/system/user@1001.service.d \
    && echo "[Service]" >> /etc/systemd/system/user@1001.service.d/override.conf \
    && echo "ExecStartPre=" >> /etc/systemd/system/user@1001.service.d/override.conf \
    && systemctl enable user@1001.service


#  ██  ██      ██████  ██    ██ ████████ ██   ██  ██████  ███    ██     ████████  ██████   ██████  ██      ███████
# ████████     ██   ██  ██  ██     ██    ██   ██ ██    ██ ████   ██        ██    ██    ██ ██    ██ ██      ██
#  ██  ██      ██████    ████      ██    ███████ ██    ██ ██ ██  ██        ██    ██    ██ ██    ██ ██      ███████
# ████████     ██         ██       ██    ██   ██ ██    ██ ██  ██ ██        ██    ██    ██ ██    ██ ██           ██
#  ██  ██      ██         ██       ██    ██   ██  ██████  ██   ████        ██     ██████   ██████  ███████ ███████

WORKDIR /home/${USER}
USER ${USER}

# Install Python packages
# Note: Not upgrading pip since it's managed by Debian package manager
# Using --ignore-installed to avoid conflicts with system-installed packages like jsonschema
RUN python -m pip install --no-cache-dir --break-system-packages --ignore-installed \
      checkov \
      detect-secrets \
      podman-compose \
      pre-commit \
      uv


#  ██  ██      ███████ ██ ███    ██  █████  ██          ███████ ███████ ████████ ██    ██ ██████
# ████████     ██      ██ ████   ██ ██   ██ ██          ██      ██         ██    ██    ██ ██   ██
#  ██  ██      █████   ██ ██ ██  ██ ███████ ██          ███████ █████      ██    ██    ██ ██████
# ████████     ██      ██ ██  ██ ██ ██   ██ ██               ██ ██         ██    ██    ██ ██
#  ██  ██      ██      ██ ██   ████ ██   ██ ███████     ███████ ███████    ██     ██████  ██

USER root
WORKDIR /home/root

RUN apt-get -y update \
    && apt-get -y upgrade \
    && printf 'export PATH="%s"\n' "${PATH}" >> /home/${USER}/.bashrc \
    && rm -rf /var/lib/apt/lists/*

# Systemd (system instance) oneshot unit to make "/" recursively shared
RUN tee /etc/systemd/system/make-root-shared.service >/dev/null <<'EOF'
[Unit]
Description=Make / a shared mount for rootless containers
DefaultDependencies=no
After=local-fs.target
Before=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/mount --make-rshared /

[Install]
WantedBy=multi-user.target
EOF

# Enable the system unit (creates the wants/ symlink)
RUN ln -s ../make-root-shared.service /etc/systemd/system/multi-user.target.wants/make-root-shared.service || true

RUN echo 'if [ -f "/home/linuxbrew/.linuxbrew/opt/bash-git-prompt/share/gitprompt.sh" ]; then' >> /home/${USER}/.bashrc \
    && echo '  __GIT_PROMPT_DIR="/home/linuxbrew/.linuxbrew/opt/bash-git-prompt/share"' >> /home/${USER}/.bashrc \
    && echo "  GIT_PROMPT_ONLY_IN_REPO=1" >> /home/${USER}/.bashrc \
    && echo '  source "/home/linuxbrew/.linuxbrew/opt/bash-git-prompt/share/gitprompt.sh"' >> /home/${USER}/.bashrc \
    && echo "fi" >> /home/${USER}/.bashrc

# Podman engine config: use systemd cgroups + journald events (per-user default via /etc/skel)
RUN mkdir -p /etc/skel/.config/containers \
 && tee /etc/skel/.config/containers/containers.conf >/dev/null <<'EOF'
[engine]
cgroup_manager = "systemd"
events_logger = "journald"
EOF

# Give the current user the same containers.conf
RUN mkdir -p /home/${USER}/.config/containers \
 && cp /etc/skel/.config/containers/containers.conf /home/${USER}/.config/containers/containers.conf \
 && chown -R ${USER}:${GROUP} /home/${USER}/.config \
 && mkdir -p /etc/containers \
 && touch /etc/containers/nodocker

# (Optional) Pre-enable podman.socket for all users' systemd --user via global wants
# This avoids needing to run `systemctl --user enable podman.socket` on first login.
# If your distro places the unit in /usr/lib/systemd/user, this symlink works for all users.
RUN test -f /usr/lib/systemd/user/podman.socket && \
    mkdir -p /etc/systemd/user/default.target.wants && \
    ln -sf /usr/lib/systemd/user/podman.socket /etc/systemd/user/default.target.wants/podman.socket || true

RUN mkdir -p /home/${USER}/.ssh \
    && echo "Host ssh.dev.azure.com" >> /home/${USER}/.ssh/config \
    && echo "  IdentityFile ~/.ssh/id_rsa" >> /home/${USER}/.ssh/config \
    && echo "  IdentitiesOnly yes" >> /home/${USER}/.ssh/config \
    && echo "  HostkeyAlgorithms +ssh-rsa" >> /home/${USER}/.ssh/config \
    && echo "  PubkeyAcceptedKeyTypes=ssh-rsa" >> /home/${USER}/.ssh/config \
    && sh -c 'echo :WSLInterop:M::MZ::/init:PF > /usr/lib/binfmt.d/WSLInterop.conf' \
    && chown -R ${USER}:${GROUP} /home/${USER} \
    && printf '\nexport PODMAN_IGNORE_CGROUPSV1_WARNING=1\n' >> /home/${USER}/.bashrc \
    && printf '\nnvm use node\n' >> /home/${USER}/.bashrc \
    && mkdir -p /run/user/1001 \
    && chown -R ${USER}:${GROUP} /home/${USER} \
    && chown ${USER}:${GROUP} /run/user/1001

# Enable "linger" for the user without calling loginctl (works in images):
# creating /var/lib/systemd/linger/<user> is equivalent to `loginctl enable-linger <user>`
RUN mkdir -p /var/lib/systemd/linger && \
    touch /var/lib/systemd/linger/${USER} && \
    chmod 0644 /var/lib/systemd/linger/${USER}


#  ██  ██      ██     ██ ███████ ██          ██    ██ ██████  ███    ██ ██   ██ ██ ████████
# ████████     ██     ██ ██      ██          ██    ██ ██   ██ ████   ██ ██  ██  ██    ██
#  ██  ██      ██  █  ██ ███████ ██          ██    ██ ██████  ██ ██  ██ █████   ██    ██
# ████████     ██ ███ ██      ██ ██           ██  ██  ██      ██  ██ ██ ██  ██  ██    ██
#  ██  ██       ███ ███  ███████ ███████       ████   ██      ██   ████ ██   ██ ██    ██

# Install wsl-vpnkit to provide network connectivity when connected to VPNs on Windows host
# See: https://github.com/sakai135/wsl-vpnkit
WORKDIR /usr/local/wsl-vpnkit
RUN wget -q https://github.com/containers/gvisor-tap-vsock/releases/download/v0.6.1/gvproxy-windows.exe \
    && wget -q https://github.com/containers/gvisor-tap-vsock/releases/download/v0.6.1/vm \
    && chmod +x ./gvproxy-windows.exe ./vm \
    && mv ./vm ./wsl-vm \
    && mv ./gvproxy-windows.exe ./wsl-gvproxy.exe

# Download wsl-vpnkit script
RUN wget -q https://raw.githubusercontent.com/sakai135/wsl-vpnkit/v0.4.1/wsl-vpnkit -O /usr/local/wsl-vpnkit/wsl-vpnkit \
    && chmod +x /usr/local/wsl-vpnkit/wsl-vpnkit \
    && ln -s /usr/local/wsl-vpnkit/wsl-vpnkit /usr/local/bin/wsl-vpnkit

# Create systemd service for wsl-vpnkit
RUN printf '[Unit]\n' > /etc/systemd/system/wsl-vpnkit.service \
    && printf 'Description=wsl-vpnkit - WSL VPN network connectivity\n' >> /etc/systemd/system/wsl-vpnkit.service \
    && printf 'After=network.target\n' >> /etc/systemd/system/wsl-vpnkit.service \
    && printf '\n' >> /etc/systemd/system/wsl-vpnkit.service \
    && printf '[Service]\n' >> /etc/systemd/system/wsl-vpnkit.service \
    && printf 'ExecStart=/usr/local/wsl-vpnkit/wsl-vpnkit\n' >> /etc/systemd/system/wsl-vpnkit.service \
    && printf 'Environment="VMEXEC_PATH=/usr/local/wsl-vpnkit/wsl-vm"\n' >> /etc/systemd/system/wsl-vpnkit.service \
    && printf 'Environment="GVPROXY_PATH=/usr/local/wsl-vpnkit/wsl-gvproxy.exe"\n' >> /etc/systemd/system/wsl-vpnkit.service \
    && printf 'Restart=always\n' >> /etc/systemd/system/wsl-vpnkit.service \
    && printf 'KillMode=mixed\n' >> /etc/systemd/system/wsl-vpnkit.service \
    && printf '\n' >> /etc/systemd/system/wsl-vpnkit.service \
    && printf '[Install]\n' >> /etc/systemd/system/wsl-vpnkit.service \
    && printf 'WantedBy=multi-user.target\n' >> /etc/systemd/system/wsl-vpnkit.service \
    && systemctl enable wsl-vpnkit.service

# Clean, ensure no bashrc has dangerous mount lines
RUN sed -i '/make-rshared/d' /etc/skel/.bashrc || true \
 && sed -i '/mount[[:space:]]\+\/[[:space:]]*$/d' /etc/skel/.bashrc || true \
 && sed -i '/make-rshared/d' /home/${USER}/.bashrc || true \
 && sed -i '/mount[[:space:]]\+\/[[:space:]]*$/d' /home/${USER}/.bashrc || true

USER ${USER}
WORKDIR /home/${USER}

ARG BUILD_DATE $BUILD_DATE
