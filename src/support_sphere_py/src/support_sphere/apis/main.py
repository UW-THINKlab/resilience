import uvicorn
from fastapi import FastAPI
from support_sphere.apis.v1 import user_apis_router

app = FastAPI()
app.include_router(user_apis_router)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
