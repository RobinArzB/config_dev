#!/bin/bash -e

while [[ "$1" != "" ]]; do
    case $1 in
        --debug ) set -x
                  ;;
    esac
    shift
done

# Directories related
BIN_PATH="${HOME}/bin"
BUILD_PATH="${HOME}/build"
GIT_PATH="${HOME}/git"

# K8s related
KUBECTL_VERSION="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
HELM_VERSION="$(curl -sL https://api.github.com/repos/helm/helm/releases/latest | jq -r '.tag_name')"
KIND_VERSION="$(curl -sL https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | jq -r '.tag_name')"
SOPS_VERSION="$(curl -sL https://api.github.com/repos/mozilla/sops/releases/latest | jq -r '.tag_name')"
AGE_VERSION="$(curl -sL https://api.github.com/repos/FiloSottile/age/releases/latest | jq -r '.tag_name')"

# Neovim related
NEOVIM_VERSION="stable"

if [ ! -z "$1" ]; then
    if [ "$1" == "stable" ]; then
        NEOVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    else
        NEOVIM_VERSION="$1"
    fi
fi

echo "Updating package lists..."
sudo apt update

echo "[INFO] Installing required packages..."
sudo apt install -y \
    make cmake git \
    gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip \
    make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python3-pip

echo "[INFO] INSTALLING NEOVIM"
echo "Checking if Neovim is already installed..."
if ! [ -d ${BUILD_PATH}/neovim ]; then
    echo "Cloning Neovim..."
    git clone https://github.com/neovim/neovim "${BUILD_PATH}/neovim"
    cd "${BUILD_PATH}/neovim/"
    echo "Checking out version $NEOVIM_VERSION..."
    git checkout $NEOVIM_VERSION
    echo "Building Neovim..."
    make -j2
    echo "Installing Neovim..."
    sudo make install -s
else
    echo "Neovim is already installed."
    cd "${BUILD_PATH}/neovim/"
    CURRENT_VERSION=$(git rev-parse --abbrev-ref HEAD)
    if [ "$CURRENT_VERSION" != "$NEOVIM_VERSION" ]; then
        echo "Switching to version $NEOVIM_VERSION..."
        git fetch origin
        git checkout $NEOVIM_VERSION
        echo "Building Neovim..."
        make clean
        make -j2
        echo "Installing Neovim..."
        sudo make install -s
    else
        echo "Neovim is already at the desired version $NEOVIM_VERSION."
    fi
fi

echo "[INFO] INSTALLING REQUIRED CLI TOOLS..."
echo "Setting up Mise-en-Place..."
if ! command -v ~/.local/bin/mise &>/dev/null; then
    echo "Mise-en-Place is not installed. Installing now..."
    curl https://mise.run | sh
else
    echo "Mise en Place is already installed."

echo "Checking if Rust is installed..."
if ! [ -x "$(command -v cargo)" ]; then
  echo "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
else
  echo "Rust is already installed."
fi

echo "[INFO] Creating required directories..."
# Create home bin directory
[ -d "${BIN_PATH}" ] || mkdir "${BIN_PATH}"

# Create build directory
[ -d "${BUILD_PATH}" ] || mkdir "${BUILD_PATH}"

# Create git directory
[ -d "${GIT_PATH}" ] || mkdir "${GIT_PATH}"


echo "[INFO] INSTALLING REQUIRED K8S TOOLS..."
# Download kubectl
[ -x "$(command -v kubectl)" ] || \
  (
  echo '=> [INFO] Install kubectl'
  curl -sL "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o "${BIN_PATH}/kubectl" && \
  chmod +x "${BIN_PATH}/kubectl" && \
  ln -sf "${BIN_PATH}/kubectl" "${BIN_PATH}/k"
  )

# Download helm
[ -x "$(command -v helm)" ] || \
  (
  echo '=> [INFO] Install helm'
  curl -sL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar xz && \
  mv ./linux-amd64/helm "${BIN_PATH}" && \
  chmod +x "${BIN_PATH}/helm" && \
  rm -rf ./linux-amd64
  )

# Download kubectx (require fzf: https://github.com/junegunn/fzf)
[ -x "$(command -v kubectx)" ] || \
  (
  echo '=> [INFO] Install kubectx'
  [ ! -d "${BUILD_PATH}/kubectx" ] && git clone -q https://github.com/ahmetb/kubectx "${PROJECTS_PATH}/tools/kubectx" 2>/dev/null; \
  ln -sf "${BUILD_PATH}/kubectx/kubectx" "${BIN_PATH}/kctx" && \
  ln -sf "${BUILD_PATH}/kubectx/kubens" "${BIN_PATH}/kns"
  )

# Download kind
[ -x "$(command -v kind)" ] || \
  (
  echo '=> [INFO] Install kind'
  curl -sL "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64" -o "${BIN_PATH}/kind"
  chmod +x "${BIN_PATH}/kind"
  )

# Download sops
[ -x "$(command -v sops)" ] || \
  (
  echo '=> [INFO] Install sops'
  curl -sL "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64" -o "${BIN_PATH}/sops"
  chmod +x "${BIN_PATH}/sops"
  )

# Download age
[ -x "$(command -v age)" ] || \
  (
  echo '=> [INFO] Install age'
  curl -sL "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz" | tar xz && \
  mv ./age/age* "${BIN_PATH}" && \
  chmod +x ${BIN_PATH}/age* && \
  rm -rf ./age
  )

