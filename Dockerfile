# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set work directory
WORKDIR /app

# Install system dependencies (if any, e.g., for OpenCV if you switch from Pillow)
# RUN apt-get update && apt-get install -y --no-install-recommends libgl1-mesa-glx
# RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code into the container
COPY ./app /app/app
COPY ./model /app/model
# If you have a .env file for production, you might copy it too, or use Docker secrets/env vars
# COPY .env.prod /app/.env

# Expose port
EXPOSE 8000

# Command to run the application
# For production, use Gunicorn with Uvicorn workers
# Example: CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "-w", "4", "-b", "0.0.0.0:8000", "app.main:app"]
# For development/simplicity:
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]