# ---- Builder stage: install build tools + Python dependencies ----
FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Install build tools needed by PyMuPDF/pypdf/Pillow/reportlab
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        libffi-dev \
        libssl-dev \
        pkg-config && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --upgrade pip && pip install -r requirements.txt

# ---- Runtime stage: slim image with only runtime system deps ----
FROM python:3.12-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install runtime system dependencies:
#   tesseract-ocr  — OCR engine for scanned-PDF fallback (pytesseract)
#   poppler-utils  — provides pdftoppm for pdf2image (PDF → image conversion)
#   libgl1         — shared lib needed by Pillow image processing
#   libglib2.0-0   — shared lib needed by Pillow
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tesseract-ocr \
        poppler-utils \
        libgl1 \
        libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# Copy installed Python packages from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application source (app/ only — tests excluded via .dockerignore)
COPY ./app ./app

# Create a dedicated non-root user and group for the application.
# This follows the principle of least privilege — the process should never run as root.
# UID/GID 1001 is chosen to avoid conflicts with system users (typically < 1000).
RUN groupadd --gid 1001 appuser && \
    useradd --uid 1001 --gid appuser --shell /bin/false --create-home appuser

# Ensure the application directory and all files are owned by the non-root user.
# /tmp must be writable for tempfile.NamedTemporaryFile and pdf2image OCR processing.
RUN chown -R appuser:appuser /app && \
    chmod 1777 /tmp

# Switch to the non-root user — all subsequent commands and the CMD run as appuser.
USER 1001:1001

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
