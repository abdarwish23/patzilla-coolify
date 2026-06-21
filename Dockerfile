# ===========================================
# PatZilla — Dockerfile for Coolify deployment
# ===========================================
# PatZilla is a modular patent information research platform
# with access to multiple data sources (EPO/OPS, DPMA, IFI Claims, etc.)
# ===========================================

FROM debian:bullseye-slim

LABEL maintainer="Coralyx"
LABEL description="PatZilla IP Navigator — Patent search platform"

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
    git \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------------------
# 2. Install pip for Python 2
# -------------------------------------------
RUN wget -q https://bootstrap.pypa.io/pip/2.7/get-pip.py -O /tmp/get-pip.py \
    && python2 /tmp/get-pip.py \
    && rm /tmp/get-pip.py

# -------------------------------------------
# 3. Pin compatible dependency versions FIRST
#    (fixes urllib3 / requests version conflict)
# -------------------------------------------
RUN pip install --no-cache-dir \
    "urllib3==1.25.11" \
    "requests==2.25.1" \
    "chardet==4.0.0" \
    "idna==2.10" \
    "certifi==2021.5.30"

# -------------------------------------------
# 4. Clone PatZilla source and install properly
#    (source install registers entry points correctly)
# -------------------------------------------
RUN git clone --depth=1 --branch v0.169.3 https://github.com/ip-tools/patzilla.git /tmp/patzilla \
    && cd /tmp/patzilla \
    && pip install --no-cache-dir . \
    && rm -rf /tmp/patzilla /root/.cache

# -------------------------------------------
# 5. Create config and data directories
# -------------------------------------------
RUN mkdir -p /etc/patzilla /var/lib/patzilla /var/log/patzilla

# -------------------------------------------
# 6. Copy entrypoint script
# -------------------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# -------------------------------------------
# 7. Expose port and set working directory
# -------------------------------------------
EXPOSE 6543
WORKDIR /var/lib/patzilla

# -------------------------------------------
# 8. Health check
# -------------------------------------------
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:6543/navigator/ || exit 1

# -------------------------------------------
# 9. Entrypoint
# -------------------------------------------
ENTRYPOINT ["/entrypoint.sh"]
