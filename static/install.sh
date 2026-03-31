#!/bin/sh
# install.sh — VibeWarden installer
#
# Downloads and installs the latest vibew binary from GitHub releases.
#
# Usage:
#   curl -sS https://vibewarden.dev/install.sh | sh
#   wget -qO- https://vibewarden.dev/install.sh | sh
#
# Environment variables:
#   VIBEW_VERSION   — Install a specific version (e.g. "v0.1.0")
#   VIBEW_INSTALL   — Override install directory (default: /usr/local/bin or ~/.local/bin)
#   VIBEW_NO_COLOR  — Disable colored output
#
# Requirements:
#   - POSIX sh (works on Alpine, Ubuntu, macOS)
#   - curl or wget
#   - tar (for .tar.gz archives)
#
# https://vibewarden.dev
# https://github.com/vibewarden/vibewarden

set -eu

# ─── Color helpers ───────────────────────────────────────────────────────────

setup_colors() {
    if [ -n "${VIBEW_NO_COLOR:-}" ] || [ ! -t 1 ]; then
        BOLD=""
        RESET=""
        RED=""
        GREEN=""
        YELLOW=""
        CYAN=""
        PURPLE=""
    else
        BOLD="\033[1m"
        RESET="\033[0m"
        RED="\033[31m"
        GREEN="\033[32m"
        YELLOW="\033[33m"
        CYAN="\033[36m"
        PURPLE="\033[35m"
    fi
}

# ─── Logging ─────────────────────────────────────────────────────────────────

info() {
    printf "${PURPLE}\\V/${RESET} %s\n" "$*"
}

success() {
    printf "${GREEN}\\V/${RESET} %s\n" "$*"
}

warn() {
    printf "${YELLOW}\\V/${RESET} %s\n" "$*" >&2
}

error() {
    printf "${RED}\\V/ Error:${RESET} %s\n" "$*" >&2
}

die() {
    error "$@"
    exit 1
}

# ─── OS / architecture detection ────────────────────────────────────────────

detect_os() {
    os="$(uname -s)"
    case "$os" in
        Linux)  echo "linux" ;;
        Darwin) echo "darwin" ;;
        *)      die "Unsupported operating system: $os. VibeWarden supports Linux and macOS." ;;
    esac
}

detect_arch() {
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64)   echo "amd64" ;;
        aarch64|arm64)  echo "arm64" ;;
        *)              die "Unsupported architecture: $arch. VibeWarden supports amd64 and arm64." ;;
    esac
}

# ─── HTTP client abstraction ────────────────────────────────────────────────

detect_http_client() {
    if command -v curl >/dev/null 2>&1; then
        echo "curl"
    elif command -v wget >/dev/null 2>&1; then
        echo "wget"
    else
        die "Neither curl nor wget found. Please install one of them."
    fi
}

# Fetch a URL to stdout.
http_get() {
    url="$1"
    case "$HTTP_CLIENT" in
        curl) curl -fsSL "$url" ;;
        wget) wget -qO- "$url" ;;
    esac
}

# Download a URL to a file.
http_download() {
    url="$1"
    dest="$2"
    case "$HTTP_CLIENT" in
        curl) curl -fsSL -o "$dest" "$url" ;;
        wget) wget -qO "$dest" "$url" ;;
    esac
}

# ─── Version resolution ─────────────────────────────────────────────────────

get_latest_version() {
    api_url="https://api.github.com/repos/vibewarden/vibewarden/releases/latest"
    response="$(http_get "$api_url")" || die "Failed to query GitHub API for the latest release."

    # Extract tag_name without requiring jq.
    version="$(printf '%s' "$response" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')"

    if [ -z "$version" ]; then
        die "Could not determine the latest version from GitHub."
    fi
    echo "$version"
}

# ─── Checksum verification ──────────────────────────────────────────────────

verify_checksum() {
    archive="$1"
    checksums_url="$2"

    checksums_file="$(mktemp)"
    if ! http_download "$checksums_url" "$checksums_file" 2>/dev/null; then
        warn "Checksums file not available — skipping verification."
        rm -f "$checksums_file"
        return 0
    fi

    archive_name="$(basename "$archive")"
    expected="$(grep "$archive_name" "$checksums_file" | awk '{print $1}')"
    rm -f "$checksums_file"

    if [ -z "$expected" ]; then
        warn "No checksum entry found for $archive_name — skipping verification."
        return 0
    fi

    if command -v sha256sum >/dev/null 2>&1; then
        actual="$(sha256sum "$archive" | awk '{print $1}')"
    elif command -v shasum >/dev/null 2>&1; then
        actual="$(shasum -a 256 "$archive" | awk '{print $1}')"
    else
        warn "No sha256sum or shasum available — skipping checksum verification."
        return 0
    fi

    if [ "$actual" != "$expected" ]; then
        die "Checksum mismatch for $archive_name.
  Expected: $expected
  Got:      $actual
This could indicate a corrupted download or a tampered file."
    fi

    info "Checksum verified."
}

# ─── Install directory selection ─────────────────────────────────────────────

determine_install_dir() {
    if [ -n "${VIBEW_INSTALL:-}" ]; then
        echo "$VIBEW_INSTALL"
        return
    fi

    if [ "$(id -u)" -eq 0 ]; then
        echo "/usr/local/bin"
        return
    fi

    # Try /usr/local/bin if writable, otherwise fall back to ~/.local/bin.
    if [ -w "/usr/local/bin" ]; then
        echo "/usr/local/bin"
    else
        echo "${HOME}/.local/bin"
    fi
}

ensure_install_dir() {
    dir="$1"
    if [ ! -d "$dir" ]; then
        info "Creating install directory: $dir"
        mkdir -p "$dir" || die "Failed to create directory: $dir"
    fi
}

needs_sudo() {
    dir="$1"
    if [ -w "$dir" ]; then
        return 1
    fi
    if command -v sudo >/dev/null 2>&1; then
        return 0
    fi
    die "Cannot write to $dir and sudo is not available. Set VIBEW_INSTALL to a writable directory."
}

# ─── Main install logic ─────────────────────────────────────────────────────

main() {
    setup_colors

    printf "\n"
    info "${BOLD}VibeWarden Installer${RESET}"
    info "Security sidecar for vibe-coded apps."
    printf "\n"

    HTTP_CLIENT="$(detect_http_client)"

    os="$(detect_os)"
    arch="$(detect_arch)"
    info "Detected platform: ${BOLD}${os}/${arch}${RESET}"

    version="${VIBEW_VERSION:-}"
    if [ -z "$version" ]; then
        info "Fetching latest version..."
        version="$(get_latest_version)"
    fi
    info "Version: ${BOLD}${version}${RESET}"

    # Build asset name. Releases use: vibew-{os}-{arch}.tar.gz
    asset_name="vibew-${os}-${arch}.tar.gz"
    checksums_name="checksums.txt"

    # Strip leading 'v' for the download URL path if present.
    base_url="https://github.com/vibewarden/vibewarden/releases/download/${version}"
    download_url="${base_url}/${asset_name}"
    checksums_url="${base_url}/${checksums_name}"

    install_dir="$(determine_install_dir)"

    info "Installing to: ${BOLD}${install_dir}${RESET}"

    # Download to a temporary directory.
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT

    info "Downloading ${asset_name}..."
    http_download "$download_url" "${tmp_dir}/${asset_name}" \
        || die "Download failed. Check that release ${version} exists at:
  ${download_url}"

    verify_checksum "${tmp_dir}/${asset_name}" "$checksums_url"

    info "Extracting..."
    tar -xzf "${tmp_dir}/${asset_name}" -C "$tmp_dir" \
        || die "Failed to extract ${asset_name}."

    # Locate the binary inside the extracted archive.
    if [ -f "${tmp_dir}/vibew" ]; then
        binary="${tmp_dir}/vibew"
    else
        die "Could not find vibew binary in the archive."
    fi

    chmod +x "$binary"

    # Install the binary.
    ensure_install_dir "$install_dir"
    if needs_sudo "$install_dir"; then
        info "Requesting elevated privileges to install to ${install_dir}..."
        sudo mv "$binary" "${install_dir}/vibew" \
            || die "Failed to install vibew to ${install_dir}."
    else
        mv "$binary" "${install_dir}/vibew" \
            || die "Failed to install vibew to ${install_dir}."
    fi

    success "vibew ${version} installed to ${install_dir}/vibew"

    # Warn if install dir is not on PATH.
    case ":${PATH}:" in
        *":${install_dir}:"*) ;;
        *)
            printf "\n"
            warn "${install_dir} is not in your PATH."
            warn "Add it with:"
            warn "  export PATH=\"${install_dir}:\$PATH\""
            ;;
    esac

    printf "\n"
    success "${BOLD}You vibe, we warden. Security is no longer your burden.${RESET}"
    printf "\n"
    info "Get started:"
    printf "\n"
    printf "  vibew init --upstream 3000 --auth --rate-limit\n"
    printf "  vibew dev\n"
    printf "\n"
    info "Docs: https://vibewarden.dev/docs/"
    printf "\n"
}

main "$@"
