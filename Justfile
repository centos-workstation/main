export repo_organization := env("GITHUB_REPOSITORY_OWNER", "centos-workstation")
export image_name := env("IMAGE_NAME", "main")
export centos_version := env("CENTOS_VERSION", "stream10")
export default_tag := env("DEFAULT_TAG", "latest")

[private]
default:
    @just --list

# Check Just Syntax
[group('Just')]
check:
    #!/usr/bin/bash
    find . -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	just --unstable --fmt --check -f $file
    done
    echo "Checking syntax: Justfile"
    just --unstable --fmt --check -f Justfile

# Fix Just Syntax
[group('Just')]
fix:
    #!/usr/bin/bash
    find . -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	just --unstable --fmt -f $file
    done
    echo "Checking syntax: Justfile"
    just --unstable --fmt -f Justfile || { exit 1; }

# Clean Repo
[group('Utility')]
clean:
    #!/usr/bin/bash
    set -eoux pipefail
    touch _build
    find *_build* -exec rm -rf {} \;
    rm -f previous.manifest.json
    rm -f changelog.md
    rm -f output.env

# Sudo Clean Repo
[group('Utility')]
[private]
sudo-clean:
    just sudoif just clean

# sudoif bash function
[group('Utility')]
[private]
sudoif command *args:
    #!/usr/bin/bash
    function sudoif(){
        if [[ "${UID}" -eq 0 ]]; then
            "$@"
        elif [[ "$(command -v sudo)" && -n "${SSH_ASKPASS:-}" ]] && [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
            /usr/bin/sudo --askpass "$@" || exit 1
        elif [[ "$(command -v sudo)" ]]; then
            /usr/bin/sudo "$@" || exit 1
        else
            exit 1
        fi
    }
    sudoif {{ command }} {{ args }}

build $target_image=image_name $tag=default_tag:
    #!/usr/bin/env bash

    # Get Version
    ver="${tag}-${centos_version}.$(date +%Y%m%d)"

    BUILD_ARGS=()
    BUILD_ARGS+=("--build-arg" "MAJOR_VERSION=${centos_version}")
    # BUILD_ARGS+=("--build-arg" "IMAGE_NAME=${image_name}")
    # BUILD_ARGS+=("--build-arg" "IMAGE_VENDOR=${repo_organization}")
    if [[ -z "$(git status -s)" ]]; then
        BUILD_ARGS+=("--build-arg" "SHA_HEAD_SHORT=$(git rev-parse --short HEAD)")
    fi

    LABELS=()
    LABELS+=("--label" "org.opencontainers.image.title=${image_name}")
    LABELS+=("--label" "org.opencontainers.image.version=${ver}")
    # LABELS+=("--label" "ostree.linux=${kernel_release}")
    LABELS+=("--label" "io.artifacthub.package.readme-url=https://raw.githubusercontent.com/ublue-os/bluefin/bluefin/README.md")
    LABELS+=("--label" "io.artifacthub.package.logo-url=https://avatars.githubusercontent.com/u/120078124?s=200&v=4")
    LABELS+=("--label" "org.opencontainers.image.description=CentOS based images")

    podman build \
        "${BUILD_ARGS[@]}" \
        "${LABELS[@]}" \
        --tag "${target_image}:${tag}" \
        .

build-vm $target_image=("localhost/" + image_name) $tag=default_tag $type="qcow2":
    #!/usr/bin/env bash
    set -euo pipefail

    if ! sudo podman image exists "${target_image}" ; then
      echo "Ensuring image is on root storage"
      COPYTMP=$(mktemp -p "${PWD}" -d -t _build_podman_scp.XXXXXXXXXX)
      sudo podman image scp "$USER@localhost::${target_image}" root@localhost::
      rm -rf "${COPYTMP}"
    fi

    echo "Cleaning up previous build"
    sudo rm -rf output || true
    mkdir -p output

    args="--type ${type}"

    if [[ $target_image == localhost/* ]]; then
      args+=" --local"
    fi

    echo "${args}"
    sudo podman run \
      --rm \
      -it \
      --privileged \
      --pull=newer \
      --security-opt label=type:unconfined_t \
      -v $(pwd)/image-builder.config.toml:/config.toml:ro \
      -v $(pwd)/output:/output \
      -v /var/lib/containers/storage:/var/lib/containers/storage \
      quay.io/centos-bootc/bootc-image-builder:latest \
      ${args} \
      "${target_image}"

      sudo chown -R $USER:$USER output
      echo "making the image biggerer"
      sudo qemu-img resize output/qcow2/disk.qcow2 80G

run-vm:
    virsh dominfo centos-workstation-main &> /dev/null && \
    ( virsh destroy centos-workstation-main ; virsh undefine centos-workstation-main ) 
    virt-install --import \
    --name centos-workstation-main \
    --disk output/qcow2/disk.qcow2,format=qcow2,bus=virtio \
    --memory 4096 \
    --vcpus 4 \
    --os-variant centos-stream9 \
    --network bridge:virbr0 \
    --graphics vnc

    virsh start centos-workstation-main
