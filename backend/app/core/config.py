import os
from functools import lru_cache
from pydantic import BaseModel, Field


class Settings(BaseModel):
    app_name: str = Field(default='ATS Resume Analyzer')
    app_version: str = Field(default='1.0.0')
    debug: bool = Field(default=False)
    host: str = Field(default='0.0.0.0')
    port: int = Field(default=8000)
    max_file_size_mb: int = Field(default=5)
    allowed_extensions: tuple[str, ...] = Field(default=('.pdf', '.docx'))
    cors_origins: tuple[str, ...] = Field(default=('*',))

    class Config:
        extra = 'ignore'


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings(
        app_name=os.getenv('APP_NAME', 'ATS Resume Analyzer'),
        app_version=os.getenv('APP_VERSION', '1.0.0'),
        debug=os.getenv('DEBUG', 'false').lower() == 'true',
        host=os.getenv('HOST', '0.0.0.0'),
        port=int(os.getenv('PORT', '8000')),
        max_file_size_mb=int(os.getenv('MAX_FILE_SIZE_MB', '5')),
        allowed_extensions=tuple(
            ext.strip().lower()
            for ext in os.getenv('ALLOWED_EXTENSIONS', '.pdf,.docx').split(',')
            if ext.strip()
        ),
        cors_origins=tuple(
            origin.strip()
            for origin in os.getenv('CORS_ORIGINS', '*').split(',')
            if origin.strip()
        ),
    )
