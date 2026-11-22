from fastapi import FastAPI

app = FastAPI(title="AWS Enterprise Platform")


@app.get("/")
def home():
    return {
        "message": "AWS Enterprise Platform is running",
        "status": "ok"
    }


@app.get("/health")
def health():
    return {"status": "healthy"}