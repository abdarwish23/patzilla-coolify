# ===========================================
# PatZilla — Dockerfile for Coolify deployment
# ===========================================
# PatZilla is a modular patent information research platform
# with access to multiple data sources (EPO/OPS, DPMA, IFI Claims, etc.)
#
# Build:  docker build -t patzilla .
# Run:    docker run -p 6543:6543 patzilla
# ===========================================

FROM debian:bullseye-slim

LABEL maintainer="Coralyx <coralyx@example.com>"
LABEL description="PatZilla IP Navigator — Patent search platform"
LABEL org.opencontainers.image.source="https://github.com/ip-tools/patzilla"

# -------------------------------------------
# 1. Install system dependencies
# -------------------------------------------
RUN apt-get update && apt-get install --yes --no-install-recommends \
    wget \
    curl \
    build-essential \
    python2 \
    python2-dev \
    libjpeg-dev \
    libfreetype-dev \
    liblcms2-dev \
    libtiff-dev \
    libffi-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    pdftk \
    poppler-utils \
    imagemagick \
    libtiff-tools \
    fontconfig \
    libfontconfig1 \
    libfreetype6 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------------------
# 2. Install pip for Python 2
# -------------------------------------------
RUN wget -q https://bootstrap.pypa.io/pip/2.7/get-pip.py -O /tmp/get-pip.py \
    && python2 /tmp/get-pip.py \
    && rm /tmp/get-pip.py

# -------------------------------------------
# 3. Install PatZilla from PyPI
# -------------------------------------------
RUN pip install --no-cache-dir patzilla==0.169.3

# -------------------------------------------
# 4. Generate default config
# -------------------------------------------
RUN mkdir -p /etc/patzilla /var/lib/patzilla /var/log/patzilla

# -------------------------------------------
# 5. Copy entrypoint script
# -------------------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# -------------------------------------------
# 6. Expose port and set working directory
# -------------------------------------------
EXPOSE 6543
WORKDIR /var/lib/patzilla

# -------------------------------------------
# 7. Health check
# -------------------------------------------
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:6543/navigator/ || exit 1

# -------------------------------------------
# 8. Entrypoint
# -------------------------------------------
ENTRYPOINT ["/entrypoint.sh"]
