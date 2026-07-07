import os
from fastapi import UploadFile

from app.core.config import get_settings
from app.core.exceptions import FileTooLargeError, UnsupportedFileTypeError, ValidationError

settings = get_settings()


def validate_upload(file: UploadFile) -> bytes:
    filename = file.filename or ''
    extension = os.path.splitext(filename)[1].lower()

    if extension not in settings.allowed_extensions:
        raise UnsupportedFileTypeError(
            f'Invalid file type. Allowed types: {", ".join(settings.allowed_extensions)}'
        )

    content = file.file.read()
    if len(content) > settings.max_file_size_mb * 1024 * 1024:
        raise FileTooLargeError('File size exceeds the configured limit')

    if not content:
        raise ValidationError('Uploaded file is empty')

    return content
