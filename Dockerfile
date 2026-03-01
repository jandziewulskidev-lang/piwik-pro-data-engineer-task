FROM python:3.12-slim

# Install system dependencies: build tools, SSL, Excel support, git (required by dbt)
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv package manager
RUN pip install uv

WORKDIR /app

# Copy dependency manifest first (leverages Docker layer caching)
COPY pyproject.toml .

# Install Python dependencies
RUN uv pip install . --system

CMD ["bash"]