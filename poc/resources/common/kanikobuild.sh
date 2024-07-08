#!/usr/bin/env bash
#
# Setup OCI image
set -eu -o pipefail

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ROOT="$(dirname "${SCRIPTPATH}")"

# Copy application
cp -a "${ROOT}/${TARGET}/"* /app/
# and shared libs
cp -a "${SCRIPTPATH}/libs/"* /app/

cd /app
pip install -r requirements.txt


# Clean not required files
find "/usr/share/doc" -depth -type f ! -name copyright -print0 \
    | xargs -0 rm || true
find "/usr/share/doc" -empty -print0 | xargs -0 rmdir || true
find "/usr/share/man" -type d ! -name "man*" -print0 | xargs -0 rm -rf || true
find "/usr/share/man" -type f -delete || true
rm -rf \
    "/usr/share/groff" \
    "/usr/share/info" \
    "/usr/share/lintian" \
    "/usr/share/linda" \
    "/usr/share/doc-base" \
    || true
