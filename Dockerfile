ARG PYTHON_VERSION=3.12-slim-bullseye
FROM python:${PYTHON_VERSION}

# Python settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /code

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libjpeg-dev \
    libcairo2 \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip once
RUN pip install --upgrade pip

# Copy requirements first (better layer caching)
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Install gunicorn + rav
RUN pip install --upgrade gunicorn rav

# Copy project
COPY ./src /code

# Environment variables
ARG DJANGO_SECRET_KEY
ENV DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}

ARG DJANGO_DEBUG=0
ENV DJANGO_DEBUG=${DJANGO_DEBUG}

# Static build steps
# COPY ./rav.yaml /tmp/rav.yaml
# RUN rav download staticfiles_prod -f /tmp/rav.yaml

RUN python manage.py collectstatic --noinput

# Runtime script
ARG PROJ_NAME="cfehome"

RUN printf "#!/bin/bash\n" > /code/run.sh && \
    printf "RUN_PORT=\"\${PORT:-8000}\"\n\n" >> /code/run.sh && \
    printf "python manage.py migrate --no-input\n" >> /code/run.sh && \
    printf "gunicorn ${PROJ_NAME}.wsgi:application --bind 0.0.0.0:\$RUN_PORT\n" >> /code/run.sh

RUN chmod +x /code/run.sh

CMD ["/code/run.sh"]