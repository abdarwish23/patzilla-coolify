# ===========================================
# PatZilla — Dockerfile for Coolify deployment
# ===========================================
# Multi-stage build: frontend (Node 14) + backend (Python 2.7)
# ===========================================

# -------------------------------------------
# Stage 1: Build frontend with Node.js 14
# -------------------------------------------
FROM node:14-bullseye-slim AS frontend-builder

RUN apt-get update && apt-get install --yes --no-install-recommends \
    git \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/ip-tools/patzilla.git /tmp/patzilla

WORKDIR /tmp/patzilla

RUN yarn install --network-timeout 600000 || yarn install

RUN yarn build

# -------------------------------------------
# Stage 2: Final image with Python 2.7
# -------------------------------------------
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
# -------------------------------------------
RUN pip install --no-cache-dir \
    "urllib3==1.25.11" \
    "requests==2.25.1" \
    "chardet==4.0.0" \
    "idna==2.10" \
    "certifi==2021.5.30"

# -------------------------------------------
# 4. Clone PatZilla source and install Python package
# -------------------------------------------
RUN git clone --depth=1 https://github.com/ip-tools/patzilla.git /tmp/patzilla \
    && cd /tmp/patzilla \
    && pip install --no-cache-dir . \
    && rm -rf /tmp/patzilla /root/.cache

# -------------------------------------------
# 5. Copy built frontend assets from stage 1
# -------------------------------------------
COPY --from=frontend-builder /tmp/patzilla/patzilla/navigator/static/assets /usr/local/lib/python2.7/dist-packages/patzilla/navigator/static/assets

# -------------------------------------------
# 6. Create config and data directories
# -------------------------------------------
RUN mkdir -p /etc/patzilla /var/lib/patzilla /var/log/patzilla

# -------------------------------------------
# 7. Copy entrypoint script
# -------------------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# -------------------------------------------
# 8. Expose port and set working directory
# -------------------------------------------
EXPOSE 6543
WORKDIR /var/lib/patzilla

# -------------------------------------------
# 9. Health check
# -------------------------------------------
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:6543/navigator/ || exit 1

# -------------------------------------------
# 10. Entrypoint
# -------------------------------------------
ENTRYPOINT ["/entrypoint.sh"]
