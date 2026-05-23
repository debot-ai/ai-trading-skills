#!/bin/sh
set -e

# debot-trade-cli installer using client artifacts from the Debot open skills repo.

BINARY_NAME="debot-trade-cli"
VERSION="v0.0.2"
INSTALL_DIR="$HOME/.local/bin"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
CLIENT_DIR="${SCRIPT_DIR}/client/${VERSION}"
CLIENT_BASE_URL="${DEBOT_TRADE_CLIENT_BASE_URL:-https://raw.githubusercontent.com/debot-ai/ai-trading-skills/main/skills/trade/client/${VERSION}}"

info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$1"; }
warn()  { printf "\033[1;33m[WARN]\033[0m  %s\n" "$1"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$1"; exit 1; }

detect_os() {
    OS_RAW=$(uname -s)
    case "$OS_RAW" in
        Linux*)               OS="linux"   ;;
        Darwin*)              OS="darwin"  ;;
        MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
        *) error "Unsupported OS: $OS_RAW" ;;
    esac
}

detect_arch() {
    ARCH_RAW=$(uname -m)
    case "$ARCH_RAW" in
        x86_64|amd64)  ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *) error "Unsupported architecture: $ARCH_RAW" ;;
    esac
}

need_cmd() {
    if ! command -v "$1" > /dev/null 2>&1; then
        error "Required command '$1' not found. Please install it first."
    fi
}

compute_md5() {
    if command -v md5sum > /dev/null 2>&1; then
        md5sum "$1" | awk '{print $1}'
    elif command -v md5 > /dev/null 2>&1; then
        md5 -q "$1"
    else
        warn "Neither md5sum nor md5 found, skipping checksum verification"
        echo ""
    fi
}

ensure_path() {
    case ":$PATH:" in
        *":$INSTALL_DIR:"*) return 0 ;;
    esac

    EXPORT_LINE="export PATH=\"\$HOME/.local/bin:\$PATH\""
    shell_name=$(basename "$SHELL" 2>/dev/null || echo "sh")

    case "$shell_name" in
        zsh) profile="$HOME/.zshrc" ;;
        bash)
            if [ -f "$HOME/.bash_profile" ]; then
                profile="$HOME/.bash_profile"
            elif [ -f "$HOME/.bashrc" ]; then
                profile="$HOME/.bashrc"
            else
                profile="$HOME/.profile"
            fi
            ;;
        *) profile="$HOME/.profile" ;;
    esac

    if [ -f "$profile" ] && grep -qF '$HOME/.local/bin' "$profile" 2>/dev/null; then
        export PATH="$INSTALL_DIR:$PATH"
        return 0
    fi

    printf '\n# Added by debot-trade-cli installer\n%s\n' "$EXPORT_LINE" >> "$profile"
    export PATH="$INSTALL_DIR:$PATH"

    info "Added $INSTALL_DIR to PATH in $profile"
    echo ""
    echo "  To use '${BINARY_NAME}' in this session, run:"
    echo "    source $profile"
    echo "  Or open a new terminal window."
}

install() {
    detect_os
    detect_arch

    if [ "$OS" = "windows" ]; then
        ARCHIVE_EXT=".zip"
    else
        ARCHIVE_EXT=".tar.gz"
        need_cmd tar
    fi

    ARCHIVE_NAME="${BINARY_NAME}-${OS}-${ARCH}${ARCHIVE_EXT}"
    CHECKSUM_NAME="checksums-md5.txt"

    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"' EXIT

    if [ -f "${CLIENT_DIR}/${ARCHIVE_NAME}" ]; then
        ARCHIVE_PATH="${CLIENT_DIR}/${ARCHIVE_NAME}"
        CHECKSUM_PATH="${CLIENT_DIR}/${CHECKSUM_NAME}"
        CLIENT_SOURCE="$ARCHIVE_PATH"
    else
        need_cmd curl
        ARCHIVE_PATH="${TMP_DIR}/${ARCHIVE_NAME}"
        CHECKSUM_PATH="${TMP_DIR}/${CHECKSUM_NAME}"
        CLIENT_SOURCE="${CLIENT_BASE_URL}/${ARCHIVE_NAME}"

        info "Downloading client from Debot open skills repo ..."
        curl -fL --retry 3 --retry-delay 1 -o "$ARCHIVE_PATH" "$CLIENT_SOURCE"
        curl -fL --retry 3 --retry-delay 1 -o "$CHECKSUM_PATH" "${CLIENT_BASE_URL}/${CHECKSUM_NAME}" || warn "MD5 checksum file not available, skipping verification"
    fi

    info "Platform: ${OS}/${ARCH}"
    info "Version:  ${VERSION}"
    info "Client:   ${CLIENT_SOURCE}"
    echo ""

    if [ ! -f "$ARCHIVE_PATH" ]; then
        error "Client archive not found: $ARCHIVE_PATH"
    fi

    if [ -f "$CHECKSUM_PATH" ]; then
        info "Verifying MD5 checksum ..."
        EXPECTED_MD5=$(awk -v f="${ARCHIVE_NAME}" '$2==f {print $1}' "$CHECKSUM_PATH")
        ACTUAL_MD5=$(compute_md5 "$ARCHIVE_PATH")

        if [ -z "$EXPECTED_MD5" ]; then
            warn "No MD5 entry found for ${ARCHIVE_NAME}, skipping verification"
        elif [ -n "$ACTUAL_MD5" ] && [ "$ACTUAL_MD5" != "$EXPECTED_MD5" ]; then
            error "MD5 mismatch! Expected: $EXPECTED_MD5  Got: $ACTUAL_MD5"
        elif [ -n "$ACTUAL_MD5" ]; then
            info "MD5 OK: $ACTUAL_MD5"
        fi
    else
        warn "MD5 checksum file not found, skipping verification"
    fi

    info "Extracting ..."
    if [ "$OS" = "windows" ]; then
        need_cmd unzip
        unzip -q "$ARCHIVE_PATH" -d "$TMP_DIR"
        BIN_FILE="${BINARY_NAME}-${OS}-${ARCH}.exe"
        INSTALLED_NAME="${BINARY_NAME}.exe"
    else
        tar xzf "$ARCHIVE_PATH" -C "$TMP_DIR"
        BIN_FILE="${BINARY_NAME}-${OS}-${ARCH}"
        INSTALLED_NAME="${BINARY_NAME}"
    fi

    if [ ! -f "${TMP_DIR}/${BIN_FILE}" ]; then
        error "Expected binary '${BIN_FILE}' not found in archive"
    fi

    mkdir -p "$INSTALL_DIR"
    mv "${TMP_DIR}/${BIN_FILE}" "${INSTALL_DIR}/${INSTALLED_NAME}"
    chmod +x "${INSTALL_DIR}/${INSTALLED_NAME}"

    ensure_path

    echo ""
    info "Successfully installed ${BINARY_NAME} ${VERSION} to ${INSTALL_DIR}/${INSTALLED_NAME}"
    echo ""
    echo "  Version:  $("${INSTALL_DIR}/${INSTALLED_NAME}" version 2>/dev/null || echo 'unknown')"
    echo ""
    echo "  Get started:"
    echo "    ${BINARY_NAME} config --api-key YOUR_KEY --api-secret YOUR_SECRET"
    echo "    ${BINARY_NAME} wallets"
    echo "    ${BINARY_NAME} trade --chain solana --token-in SOL_ADDR --token-out TOKEN --amount 1000000000 --public-key WALLET"
    echo ""
    echo "  If '${BINARY_NAME}' is not found, restart your terminal or run:"
    echo "    export PATH=\"${INSTALL_DIR}:\$PATH\""
    echo ""
}

install
