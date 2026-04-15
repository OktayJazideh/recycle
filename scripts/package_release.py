from __future__ import annotations

import pathlib
import sys
import zipfile

VERSION = sys.argv[1] if len(sys.argv) > 1 else '2.0.0'
PROJECT_ROOT = pathlib.Path(__file__).resolve().parents[1]
OUTPUT_DIR = PROJECT_ROOT / 'release'
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
ARCHIVE_PATH = OUTPUT_DIR / f'project_backup_v{VERSION}.zip'

EXCLUDED_PARTS = {
    '.git',
    'node_modules',
    'build',
    '.dart_tool',
    'Pods',
    '.gradle',
    'release',
}

with zipfile.ZipFile(ARCHIVE_PATH, 'w', compression=zipfile.ZIP_DEFLATED) as archive:
    for path in PROJECT_ROOT.rglob('*'):
        if any(part in EXCLUDED_PARTS for part in path.parts):
            continue
        if path.is_file():
            archive.write(path, path.relative_to(PROJECT_ROOT))

print(ARCHIVE_PATH)
