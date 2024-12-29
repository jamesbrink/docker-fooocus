ARG BASE_IMAGE=nvidia/cuda:12.6.3-runtime-ubuntu22.04
FROM ${BASE_IMAGE} AS base

# Install deps
RUN set -xe; \
    apt update && apt install -y \
        bash-completion \
        curl \
        ffmpeg \
        git \
        iproute2 \
        libgl1-mesa-glx \
        libglib2.0-0 \
        python-is-python3 \
        python3 \
        python3-pip \
        rsync \
        sudo \
        vim \
        wget; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /var/cache/apt;

# Create our user
RUN set -xe; \
    useradd -u 1000 -g 100 -G sudo -r -d /fooocus -s /bin/sh fooocus; \
    echo "fooocus ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
    mkdir -p /fooocus;

# Setup Fooocus
ARG VERSION=v2.5.5
RUN set -xe; \
    git clone https://github.com/lllyasviel/fooocus.git /fooocus; \
    mkdir -p /fooocus/outputs; \
    cd /fooocus; \
    git fetch --all --tags; \
    git checkout ${VERSION}; \
    pip install --no-cache-dir -r requirements_versions.txt; \
    cp -rvp /fooocus/models /fooocus/fresh_models;


# Copy our entrypoint into the container.
COPY ./runtime-assets /

# Ensure entrypoint is executable
RUN set -xe; \
    chmod 0755 /usr/local/bin/entrypoint.sh; \
    chown -R fooocus:users /fooocus;

# Labels / Metadata.
LABEL \
    org.opencontainers.image.authors="James Brink <brink.james@gmail.com>" \
    org.opencontainers.image.description="Fooocus Interface for Stable Diffusion" \
    org.opencontainers.image.source="https://github.com/jamesbrink/fooocus" \
    org.opencontainers.image.title="fooocus" \
    org.opencontainers.image.vendor="jamesbrink" \
    org.opencontainers.image.version="${VERSION}"

# Setup our environment variables.
ENV \
    HOME="/fooocus" \
    PATH="/usr/local/bin:$PATH" \
    VERSION="${VERSION}"

# Drop down to our unprivileged user.
USER fooocus
WORKDIR /fooocus

# Setup git
RUN set -xe; \
    git config --global user.name "Fooocus"; \
    git config --global user.email "Fooocus@urandom.io"; \
    git config --global init.defaultBranch main; \
    git config --global core.editor "vim"; \
    git config --global --add safe.directory /comfyui; \
    git config --global --add safe.directory /comfyui/custom_nodes/ComfyUI-Manager;

# Expose our ports
EXPOSE 7865

# Volumes
VOLUME [ "/fooocus/models", "/fooocus/outputs" ]

# # Set the entrypoint.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Set the default command
CMD [ "--listen", "--preset", "realistic" ]
