from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
# from prometheus_fastapi_instrumentator import Instrumentator


from app import get_settings
from app.api.exception_handlers import register_exception_handlers
from app.api.routers.analyze import router as analyze_router
from app.api.routers.system import router as system_router

settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    description='AI-powered resume analysis and ATS scoring',
    version=settings.app_version,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=list(settings.cors_origins),
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)

register_exception_handlers(app)
app.include_router(system_router)
app.include_router(analyze_router)

# Instrumentator().instrument(app).expose(app)

if __name__ == '__main__':
    import uvicorn

    uvicorn.run(app, host=settings.host, port=settings.port)
