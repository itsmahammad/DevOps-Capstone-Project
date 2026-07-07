class AppError(Exception):
    def __init__(self, message: str, status_code: int = 500, error_code: str = 'internal_error'):
        super().__init__(message)
        self.message = message
        self.status_code = status_code
        self.error_code = error_code


class ValidationError(AppError):
    def __init__(self, message: str, error_code: str = 'validation_error'):
        super().__init__(message, status_code=400, error_code=error_code)


class UnsupportedFileTypeError(ValidationError):
    def __init__(self, message: str):
        super().__init__(message, error_code='invalid_file_type')


class FileTooLargeError(ValidationError):
    def __init__(self, message: str):
        super().__init__(message, error_code='file_too_large')


class ParsingError(AppError):
    def __init__(self, message: str):
        super().__init__(message, status_code=422, error_code='parsing_failed')


class OCRProcessingError(AppError):
    def __init__(self, message: str):
        super().__init__(message, status_code=422, error_code='ocr_failed')


class AnalysisError(AppError):
    def __init__(self, message: str):
        super().__init__(message, status_code=502, error_code='analysis_failed')
