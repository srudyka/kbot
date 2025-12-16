#!/usr/bin/env sh
set -eu

GITLEAKS_REPO="https://github.com/gitleaks/gitleaks"
INSTALL_DIR="${HOME}/.local/bin"
GITLEAKS_BIN="${INSTALL_DIR}/gitleaks"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin) OS_NAME="darwin" ;;
  Linux)  OS_NAME="linux" ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

case "$ARCH" in
  x86_64|amd64) ARCH_NAME="x64" ;;
  arm64|aarch64) ARCH_NAME="arm64" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

VERSION="$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest \
  | grep '"tag_name"' \
  | cut -d '"' -f4)"

if [ -z "$VERSION" ]; then
  echo "Failed to fetch gitleaks version"
  exit 1
fi

ARCHIVE="gitleaks_${VERSION#v}_${OS_NAME}_${ARCH_NAME}.tar.gz"
URL="${GITLEAKS_REPO}/releases/download/${VERSION}/${ARCHIVE}"

mkdir -p "$INSTALL_DIR"

TMP_DIR="$(mktemp -d)"
curl -sSL "$URL" -o "$TMP_DIR/gitleaks.tar.gz"
tar -xzf "$TMP_DIR/gitleaks.tar.gz" -C "$TMP_DIR"

mv "$TMP_DIR/gitleaks" "$GITLEAKS_BIN"
chmod +x "$GITLEAKS_BIN"

rm -rf "$TMP_DIR"

echo "Gitleaks installed at $GITLEAKS_BIN"
echo "Ensure \$HOME/.local/bin is in your PATH"

