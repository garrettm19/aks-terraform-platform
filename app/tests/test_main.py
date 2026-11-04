import sys
from pathlib import Path

from fastapi.testclient import TestClient

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from main import app  # noqa: E402

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_predict():
    response = client.get("/predict", params={"score": 100})
    assert response.status_code == 200
    assert abs(response.json()["predicted_value"] - 110) < 1e-9


def test_predict_requires_integer_score():
    response = client.get("/predict", params={"score": "abc"})
    assert response.status_code == 422


def test_predict_requires_score():
    response = client.get("/predict")
    assert response.status_code == 422
