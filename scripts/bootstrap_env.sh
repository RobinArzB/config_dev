#!/bin/bash -e

while [[ "$1" != "" ]]; do
    case $1 in
        --debug ) set -x
                  ;;
    esac
    shift
done

BIN_PATH="${XDG_CONFIG_HOME}/bin"
BUILD_PATH="${HOME}/build"

KUBECTL_VERSION="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
HELM_VERSION="$(curl -sL https://api.github.com/repos/helm/helm/releases/latest | jq -r '.tag_name')"
KIND_VERSION="$(curl -sL https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | jq -r '.tag_name')"
SOPS_VERSION="$(curl -sL https://api.github.com/repos/mozilla/sops/releases/latest | jq -r '.tag_name')"
AGE_VERSION="$(curl -sL https://api.github.com/repos/FiloSottile/age/releases/latest | jq -r '.tag_name')"

# Create home bin directory
[ -d "${BIN_PATH}" ] || mkdir "${BIN_PATH}"

# Create projects directory
[ -d "${BUILD_PATH}" ] || mkdir "${BUILD_PATH}"

# Download kubectl
[ -x "$(command -v kubectl)" ] || \
  (
  echo '=> Install kubectl'
  curl -sL "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o "${BIN_PATH}/kubectl" && \
  chmod +x "${BIN_PATH}/kubectl" && \
  ln -sf "${BIN_PATH}/kubectl" "${BIN_PATH}/k"
  )

# Download helm
[ -x "$(command -v helm)" ] || \
  (
  echo '=> Install helm'
  curl -sL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar xz && \
  mv ./linux-amd64/helm "${BIN_PATH}" && \
  chmod +x "${BIN_PATH}/helm" && \
  rm -rf ./linux-amd64
  )

# Download kubectx (require fzf: https://github.com/junegunn/fzf)
[ -x "$(command -v kubectx)" ] || \
  (
  echo '=> Install kubectx'
  [ ! -d "${BUILD_PATH}/kubectx" ] && git clone -q https://github.com/ahmetb/kubectx "${PROJECTS_PATH}/tools/kubectx" 2>/dev/null; \
  ln -sf "${BUILD_PATH}/kubectx/kubectx" "${BIN_PATH}/kctx" && \
  ln -sf "${BUILD_PATH}/kubectx/kubens" "${BIN_PATH}/kns"
  )

# Download kind
[ -x "$(command -v kind)" ] || \
  (
  echo '=> Install kind'
  curl -sL "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64" -o "${BIN_PATH}/kind"
  chmod +x "${BIN_PATH}/kind"
  )

# Download sops
[ -x "$(command -v sops)" ] || \
  (
  echo '=> Install sops'
  curl -sL "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64" -o "${BIN_PATH}/sops"
  chmod +x "${BIN_PATH}/sops"
  )

# Download age
[ -x "$(command -v age)" ] || \
  (
  echo '=> Install age'
  curl -sL "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz" | tar xz && \
  mv ./age/age* "${BIN_PATH}" && \
  chmod +x ${BIN_PATH}/age* && \
  rm -rf ./age
  )
