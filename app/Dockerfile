# Use Python 3.12 slim image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# We use --no-cache-dir because we are ready for production and
# the cache helps with not having to reinstall certain dependencies

# Copy application code
COPY . .

# Expose port
EXPOSE 80

# Run FastAPI with uvicorn
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
