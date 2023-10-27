#!/bin/bash
# 1. Build the base stilt image.
# 2. Build the custom stilt image.
# 3. Save the custom stilt image as a tarball.

set -eux
set -o pipefail

TAG_BASE=${TAG_BASE:-stiltbase}
TAG_CUSTOM=${TAG_CUSTOM:-stiltcustom}
   
function vault {
    val=$(cd ../devops && ansible-vault decrypt --output - \
          group_vars/all/vault.yml | awk "\$1 ~ /^$1/ { print \$2 }")
    if [[ -z "$val" ]]; then
        1>&2 echo "Could not find value for $1"
        exit 1
    fi
    echo "$val"
}

if [[ "${JENASVNUSER+set}" != set ]]; then
    JENASVNUSER="$(vault vault_stilt_jena_user)"
fi

if [[ "${JENASVNPASSWORD+set}" != set ]]; then
    JENASVNPASSWORD="$(vault vault_stilt_jena_password)"
fi

ARGS=(--build-arg=JENASVNUSER=${JENASVNUSER}
      --build-arg=JENASVNPASSWORD=${JENASVNPASSWORD})

docker build --pull --tag="$TAG_BASE" "${ARGS[@]}" base

DOCKERFILE="$PWD/custom/Dockerfile.tmp"
trap 'rm -f -- "$DOCKERFILE"' EXIT
sed "s/^FROM.*/FROM $TAG_BASE/" custom/Dockerfile > "$DOCKERFILE"

docker build --tag="$TAG_CUSTOM" -f "$DOCKERFILE" custom

CUSTOM_ID=$(docker images | awk "\$1 ~ /^$TAG_CUSTOM\$/ { print \$3 }")
OUTPUT_FN="$TAG_CUSTOM-$CUSTOM_ID.tgz"

echo "docker save $TAG_CUSTOM | gzip -c > $OUTPUT_FN"
