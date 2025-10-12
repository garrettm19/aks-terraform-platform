from fastapi import FastAPI

app = FastAPI()

@app.get("/predict")
def predict(student_score: int):
    improvement = student_score * 1.1
    return {"predicted_improvement": improvement}

# Example endpoint: http://localhost:8080/predict?student_score=100