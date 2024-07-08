#!/usr/bin/env bash
set -eux
set -o pipefail

SCRIPT="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO="$(dirname "$(dirname "${SCRIPT_DIR}")")"

# Parametrization
CONTAINER_REGISTRY=${CONTAINER_REGISTRY:-registry.localhost}
BUILD_IMAGE=${CONTAINER_BUILD_IMAGE:-bitnami/python:3.11}
TARGET=${TARGET:-frontend}
CONTAINER_IMAGE_NAME=poc-${TARGET}
IMAGE=docker://${BUILD_IMAGE}

#################
#  is_rootless  #
#################
is_rootless() {
    [ "$(id -u)" -ne 0 ]
}

## Steps in this demo use pkg-managers like dnf and yum which
## must be invoked as root. Similarly `buildah mount` only work
## as root. The `buildah unshare` command switches your user
## session to root within the user namespace.
if is_rootless; then
    buildah unshare "${SCRIPT_DIR}/${SCRIPT}"
    exit $?
fi

source "${SCRIPT_DIR}/libs.sh"


# Load image
CTR=$(buildah from --userns host "${IMAGE}")
add_on_err "buildah rm ${CTR}"

MNT=$(buildah mount $CTR)
add_on_err "umount ${MNT}"

rsync -av --exclude "*.pyc" --exclude '__pycache__' "${REPO}/resources/${TARGET}/"* "${MNT}/app/"
#buildah run ${CTR} -- install_packages podman buildah fuse-overlayfs skopeo make bash git curl ca-certificates usrmerge

buildah run "${CTR}" -- bash -c "pip install -r requirements.txt"

buildah run "${CTR}" -- bash -c "find /app -exec touch --date=@0 '{}' \;"

#on_err_run_till umount

buildah config --user 1000 --cmd '["uvicorn" "app.main:app"]' "${CTR}"
buildah commit --omit-timestamp "${CTR}" "${CONTAINER_IMAGE_NAME}"
