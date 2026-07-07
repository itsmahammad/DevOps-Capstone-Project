import os
import re


def sanitize_filename(filename: str) -> str:
    base_name, ext = os.path.splitext(filename or 'upload')
    safe_base = re.sub(r'[^A-Za-z0-9._-]+', '-', base_name).strip('-.') or 'upload'
    safe_ext = re.sub(r'[^A-Za-z0-9._-]+', '', ext).lower() or '.bin'
    return f'{safe_base}{safe_ext}'
