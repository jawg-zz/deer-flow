# Use a minimal base image with Python 3.12 and uv pre-installed.
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# Ensure working directory is consistent early on.
WORKDIR /app

# Pre-copy and install only the dependency files to leverage Docker layer caching.
COPY pyproject.toml uv.lock ./

# Install dependencies and cache uv downloads to speed up rebuilds.
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --no-install-project

# Now copy the full application source after dependencies are cached.
COPY . .

# Install any application-specific dependencies if needed (skip if already done above).
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync

# Let Docker and Coolify know which port to expose.
EXPOSE 8000

# Use exec form CMD for better signal handling and compatibility.
CMD ["uv", "run", "python", "server.py", "--host", "0.0.0.0", "--port", "8000"]
