#!/bin/bash
# ex: set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab:

set -eu

TEST=${TEST:-}

docker_tag() {
    image="$1"
    filter="$2"
    curl --silent https://registry.hub.docker.com/v1/repositories/${image}/tags | \
        jq -r ".[].name | select(. | test(\"${filter}\"))"
}


for file in $(find . -name Dockerfile); do
    image_and_tag="$(sed -nE 's/FROM[[:space:]]+//p' "${file}")"
    tag="${image_and_tag##*:}"
    image="${image_and_tag%:$tag}"

    ### Figure out when to switch/upgrade to the new version ###
    # Before version 18 it was possible to use the tag "production", but now that is only
    # available for paying customers. Nextcloud change how the tags works.
    # The benefit of the production tag, is that it doesn't update right away, when a new
    # major version comes out, but instead would wait 2 releases.
    # This if statement in the script was created to re-create the functionality
    # there was previously provided by the production tag.
    if [ "${image}" == "nextcloud" ]; then
        _branch=${tag##*-}
        _version=${tag%-$_branch}
        [ "${_version}" == production ] && _version=17

        # Check if we are far enough into the next major release to that we want to upgrade
        _check_new_version=$(expr ${_version} + 1)
        [ -n "$(docker_tag "${image}" "^${_check_new_version}[0-9.]*5-${_branch}$")" ] && _version="${_check_new_version}"

        image_and_tag="${image}:${_version}-${_branch}"

        # Only pull new image if the envirement variable `TEST` is not set else `echo` the image
        if [ -z "${TEST}" ]; then
            sed -iE "s/^FROM[[:space:]].*/FROM ${image_and_tag}/" "${file}"
        else
            echo "TEST: Set the new Nextcloud image to be '${image_and_tag}' in the file: ${file}"
        fi
    fi

    # Only pull new image if the envirement variable `TEST` is not set else `echo` the image
    if [ -z "${TEST}" ]; then
        docker pull "${image_and_tag}"
    else
        echo "TEST: Pull the image '${image_and_tag}'"
    fi
done

# Only run if the envirement variable `TEST` is not set
[ -z "${TEST}" ] && docker-compose -f ~/nextcloud/docker-compose.yml pull

