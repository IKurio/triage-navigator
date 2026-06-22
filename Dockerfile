# Slim Python base — small and fast
FROM python:3.11-slim-bookworm

WORKDIR /app

# System deps: build tools for some Python packages, curl for the health check
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Install deps first so Docker can cache this layer (deps change less than code)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest: your code + the prebuilt chroma_db/ folder
COPY . .

EXPOSE 8501

# Health check (uses ${PORT} so it also works on Render)
HEALTHCHECK CMD curl --fail http://localhost:${PORT:-8501}/_stcore/health || exit 1

# Shell form so ${PORT} expands. Defaults to 8501 locally; Render overrides it.
CMD streamlit run ui/app.py \
    --server.port=${PORT:-8501} \
    --server.address=0.0.0.0 \
    --server.headless=true