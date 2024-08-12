ARG BASE_IMAGE=nvidia/cuda:12.2.2-runtime-ubuntu22.04
FROM ${BASE_IMAGE}

# Install deps
RUN set -xe; \
    apt update && apt install -y \
        curl \
        git \
        iproute2 \
        libgl1-mesa-glx \
        libglib2.0-0 \
        python-is-python3 \
        python3 \
        python3-pip \
        rsync \
        wget; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /var/cache/apt;

# Create our user
RUN set -xe; \
    useradd -u 1000 -g 100 -r -d /fooocus -s /bin/sh fooocus; \
    mkdir -p /fooocus;

# Setup Fooocus
ARG VERSION=v2.5.3
RUN set -xe; \
    git clone --branch ${VERSION} --depth 1 https://github.com/lllyasviel/fooocus.git /fooocus; \
    mkdir -p /fooocus/outputs; \
    cd /fooocus; \
    pip install --no-cache-dir -r requirements_versions.txt; \
    cp -rvp /fooocus/models /fooocus/fresh_models;


# Copy our entrypoint into the container.
COPY ./runtime-assets /

# Ensure entrypoint is executable
RUN set -xe; \
    chmod 0755 /usr/local/bin/entrypoint.sh; \
    chown -R fooocus:users /fooocus;

ARG VCS_REF
ARG BUILD_DATE

# Labels / Metadata.
LABEL \
    org.opencontainers.image.authors="James Brink <brink.james@gmail.com>" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.description="Fooocus Interface for Stable Diffusion" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.source="https://github.com/jamesbrink/fooocus" \
    org.opencontainers.image.title="fooocus" \
    org.opencontainers.image.vendor="jamesbrink" \
    org.opencontainers.image.version="${VERSION}"

# Setup our environment variables.
ENV \
    PATH="/usr/local/bin:$PATH" \
    VERSION="${VERSION}"

# Drop down to our unprivileged user.
USER fooocus
WORKDIR /fooocus

# Expose our ports
EXPOSE 7865

# Volumes
VOLUME [ "/fooocus/models", "/fooocus/outputs" ]

# # Set the entrypoint.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Set the default command
CMD [ "--listen", "--preset", "realistic" ]
