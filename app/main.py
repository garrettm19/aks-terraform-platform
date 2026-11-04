from fastapi import FastAPI

app = FastAPI(title="AKS Terraform Platform API")


@app.get("/health")
def health():
    """Liveness/readiness endpoint used by the Kubernetes probes."""
    return {"status": "ok"}


@app.get("/predict")
def predict(score: int):
    """Example endpoint: returns the input score scaled by 1.1."""
    return {"predicted_value": score * 1.1}


# The container listens on port 80 (see Dockerfile).
# Locally: uvicorn main:app --port 8000, then
# http://localhost:8000/predict?score=100
