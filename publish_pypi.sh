#!/usr/bin/env bash
# Build and publish proxsync to PyPI.
#
# Usage:
#   TWINE_PASSWORD=pypi-xxxxxxxx ./publish_pypi.sh
#
# TWINE_PASSWORD must be a PyPI API token (starts with "pypi-").
# The token is never stored by this script — only read from the environment.

set -euo pipefail
cd "$(dirname "$0")"

PACKAGE="proxsync"
VERSION=$(grep -m1 '^version' pyproject.toml | sed -E 's/version = "(.*)"/\1/')

if [ -z "${TWINE_PASSWORD:-}" ]; then
    echo "Error: set TWINE_PASSWORD to your PyPI API token first." >&2
    echo "  TWINE_PASSWORD=pypi-xxxxxxxx $0" >&2
    exit 1
fi
export TWINE_USERNAME="__token__"

echo "==> Publishing $PACKAGE $VERSION to PyPI"

echo "==> Ensuring build tools are installed"
python3 -m pip install --quiet --upgrade build twine

echo "==> Checking whether $VERSION is already published (PyPI won't allow re-uploading a version)"
if curl -fsS "https://pypi.org/pypi/${PACKAGE}/${VERSION}/json" >/dev/null 2>&1; then
    echo "Error: ${PACKAGE} ${VERSION} already exists on PyPI. Bump the version in pyproject.toml first." >&2
    exit 1
fi

echo "==> Cleaning previous build artifacts"
rm -rf dist build ./*.egg-info

echo "==> Building sdist and wheel"
python3 -m build

echo "==> Build artifacts:"
ls -la dist/

read -rp "Upload the artifacts above to PyPI as ${PACKAGE} ${VERSION}? [y/N] " confirm
if [[ "${confirm}" != "y" && "${confirm}" != "Y" ]]; then
    echo "Aborted — nothing was uploaded."
    exit 1
fi

python3 -m twine upload dist/*

echo "==> Done. Verify with: pip index versions ${PACKAGE}"
