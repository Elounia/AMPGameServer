#!/usr/bin/env bash
set -euo pipefail

APP_ID="elounia-conan-exiles-enhanced"
APP_NAME="Conan Exiles Enhancen (Elounia)"
LEGACY_LOCAL_APP_ID="conan-exiles-enhanced"
DEFAULT_INSTANCES_ROOT="/home/amp/.ampdata/instances"
DEFAULT_CACHE_SUFFIX="Plugins/ADSModule/DeploymentTemplates/CubeCoders-AMPTemplates-main"

usage() {
  cat <<'USAGE'
Install the Conan Exiles Enhancen (Elounia) AMP template into a local AMP ADS template cache.

Usage:
  bash "Conan Exiles/scripts/linux-install-conan-exiles-enhanced-amp.sh" [options]

Options:
  --instances-root PATH   AMP instances root. Default: /home/amp/.ampdata/instances
  --ads-instance NAME     ADS instance name to target, for example ADS01.
  --template-cache PATH   Direct path to the ADS deployment template cache.
  --no-restart           Copy and validate the template without restarting ADS.
  --no-backup            Do not create backups of existing template files.
  --no-commit            Do not commit changes in AMP's local template-cache git repo.
  --dry-run              Validate source files and print the detected target without copying.
  -h, --help             Show this help.

The script installs elounia-conan-exiles-enhanced template files. It does not
delete existing AMP instances, datastores, saves, or Legacy Conan Exiles
configuration.
USAGE
}

log() {
  printf '[%s] %s\n' "$APP_NAME" "$*"
}

die() {
  printf '[%s] ERROR: %s\n' "$APP_NAME" "$*" >&2
  exit 1
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONAN_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$CONAN_ROOT/Template"
INSTANCES_ROOT="$DEFAULT_INSTANCES_ROOT"
ADS_INSTANCE=""
TEMPLATE_CACHE=""
RESTART_ADS=1
BACKUP=1
COMMIT=1
DRY_RUN=0

ORIGINAL_ARGS=("$@")

while (($#)); do
  case "$1" in
    --instances-root)
      [[ $# -ge 2 ]] || die "--instances-root requires a path"
      INSTANCES_ROOT="$2"
      shift 2
      ;;
    --ads-instance)
      [[ $# -ge 2 ]] || die "--ads-instance requires a name"
      ADS_INSTANCE="$2"
      shift 2
      ;;
    --template-cache)
      [[ $# -ge 2 ]] || die "--template-cache requires a path"
      TEMPLATE_CACHE="$2"
      shift 2
      ;;
    --no-restart)
      RESTART_ADS=0
      shift
      ;;
    --no-backup)
      BACKUP=0
      shift
      ;;
    --no-commit)
      COMMIT=0
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

TEMPLATE_FILES=(
  "$APP_ID.kvp"
  "$APP_ID"config.json
  "$APP_ID"metaconfig.json
  "$APP_ID"ports.json
  "$APP_ID"updates.json
)

LEGACY_LOCAL_FILES=(
  "$LEGACY_LOCAL_APP_ID.kvp"
  "$LEGACY_LOCAL_APP_ID"config.json
  "$LEGACY_LOCAL_APP_ID"metaconfig.json
  "$LEGACY_LOCAL_APP_ID"ports.json
  "$LEGACY_LOCAL_APP_ID"updates.json
)

validate_source() {
  [[ -d "$TEMPLATE_DIR" ]] || die "Template directory not found: $TEMPLATE_DIR"

  for file in "${TEMPLATE_FILES[@]}"; do
    [[ -f "$TEMPLATE_DIR/$file" ]] || die "Missing template file: $TEMPLATE_DIR/$file"
  done

  validate_template_set "$TEMPLATE_DIR"
}

validate_template_set() {
  local template_set_dir="$1"
  local json_files=(
    "$template_set_dir/$APP_ID"config.json
    "$template_set_dir/$APP_ID"metaconfig.json
    "$template_set_dir/$APP_ID"ports.json
    "$template_set_dir/$APP_ID"updates.json
  )

  if command -v python3 >/dev/null 2>&1; then
    for file in "${json_files[@]}"; do
      python3 -m json.tool "$file" >/dev/null
    done
  elif command -v jq >/dev/null 2>&1; then
    jq empty "${json_files[@]}"
  else
    die "Need python3 or jq to validate JSON"
  fi

  grep -qx 'Meta.OS=Windows, Linux' "$template_set_dir/$APP_ID.kvp" || die "Template is not marked for Windows and Linux"
  grep -qx "Meta.DisplayName=$APP_NAME" "$template_set_dir/$APP_ID.kvp" || die "Template display name is not $APP_NAME"
  grep -q 'ConanSandboxServer-Win64-Shipping.exe' "$template_set_dir/$APP_ID.kvp" || die "Windows executable path is missing"
  grep -q 'ConanSandboxServer-Linux-Shipping' "$template_set_dir/$APP_ID.kvp" || die "Linux executable path is missing"
  grep -q '"Port": 30002' "$template_set_dir/$APP_ID"ports.json || die "Game port default must be 30002"
  grep -q '"Port": 30003' "$template_set_dir/$APP_ID"ports.json || die "Query port default must be 30003"
  grep -q '"Port": 30004' "$template_set_dir/$APP_ID"ports.json || die "Pinger port default must be 30004 to avoid the query port"
  grep -q '"Port": 30005' "$template_set_dir/$APP_ID"ports.json || die "RCON port default must be 30005"
  if grep -q 'ForceDownloadPlatform' "$template_set_dir/$APP_ID"updates.json; then
    die "Update manifest must not force a single Steam platform"
  fi
}

find_template_cache() {
  if [[ -n "$TEMPLATE_CACHE" ]]; then
    [[ -d "$TEMPLATE_CACHE" ]] || die "Template cache not found: $TEMPLATE_CACHE"
    return
  fi

  if [[ -n "$ADS_INSTANCE" ]]; then
    TEMPLATE_CACHE="$INSTANCES_ROOT/$ADS_INSTANCE/$DEFAULT_CACHE_SUFFIX"
    [[ -d "$TEMPLATE_CACHE" ]] || die "Template cache not found: $TEMPLATE_CACHE"
    return
  fi

  [[ -d "$INSTANCES_ROOT" ]] || die "AMP instances root not found or not readable: $INSTANCES_ROOT"

  mapfile -t candidates < <(find "$INSTANCES_ROOT" -maxdepth 5 -type d -path "*/$DEFAULT_CACHE_SUFFIX" 2>/dev/null | sort)
  [[ ${#candidates[@]} -gt 0 ]] || die "No ADS deployment template cache found under $INSTANCES_ROOT"

  if [[ ${#candidates[@]} -eq 1 ]]; then
    TEMPLATE_CACHE="${candidates[0]}"
    return
  fi

  for candidate in "${candidates[@]}"; do
    if [[ "$candidate" == "$INSTANCES_ROOT/ADS01/$DEFAULT_CACHE_SUFFIX" ]]; then
      TEMPLATE_CACHE="$candidate"
      return
    fi
  done

  printf 'Found multiple ADS template caches:\n' >&2
  printf '  %s\n' "${candidates[@]}" >&2
  die "Re-run with --ads-instance NAME or --template-cache PATH"
}

ads_instance_name() {
  if [[ -n "$ADS_INSTANCE" ]]; then
    printf '%s\n' "$ADS_INSTANCE"
    return
  fi

  if [[ "$TEMPLATE_CACHE" == "$INSTANCES_ROOT"/* ]]; then
    local relative="${TEMPLATE_CACHE#"$INSTANCES_ROOT"/}"
    printf '%s\n' "${relative%%/*}"
    return
  fi

  local instance_dir="${TEMPLATE_CACHE%/$DEFAULT_CACHE_SUFFIX}"
  basename "$instance_dir"
}

run_as_owner() {
  local owner_user="$1"
  shift

  if [[ "$owner_user" != "root" ]] && id "$owner_user" >/dev/null 2>&1; then
    runuser -u "$owner_user" -- "$@"
  else
    "$@"
  fi
}

restore_official_conan_template_if_overwritten() {
  local owner_user="$1"
  local owner_group="$2"
  local backup_root="$3"
  local timestamp="$4"

  [[ -f "$LEGACY_LOCAL_APP_ID.kvp" ]] || return 0
  if ! grep -q 'Elounia' "$LEGACY_LOCAL_APP_ID.kvp"; then
    return 0
  fi

  local legacy_backup_dir="$backup_root/$LEGACY_LOCAL_APP_ID-overwritten-by-elounia/$timestamp"
  install -d -o "$owner_user" -g "$owner_group" -m 0755 "$legacy_backup_dir"

  for file in "${LEGACY_LOCAL_FILES[@]}"; do
    if [[ -f "$file" ]]; then
      install -o "$owner_user" -g "$owner_group" -m 0644 "$file" "$legacy_backup_dir/$file"
    fi
  done

  log "Found older Elounia template using CubeCoders' official conan-exiles-enhanced file names."

  local restored=0
  if [[ -d .git ]] && command -v git >/dev/null 2>&1; then
    run_as_owner "$owner_user" git fetch origin main >/dev/null 2>&1 || true
    local tmp_file
    for file in "${LEGACY_LOCAL_FILES[@]}"; do
      if run_as_owner "$owner_user" git cat-file -e "origin/main:$file" 2>/dev/null; then
        tmp_file="$(mktemp)"
        run_as_owner "$owner_user" git show "origin/main:$file" > "$tmp_file"
        install -o "$owner_user" -g "$owner_group" -m 0644 "$tmp_file" "$file"
        rm -f "$tmp_file"
        restored=1
      fi
    done
  fi

  if [[ $restored -eq 1 ]]; then
    log "Restored CubeCoders' official conan-exiles-enhanced files from the AMP template repository."
  else
    rm -f "${LEGACY_LOCAL_FILES[@]}"
    log "Moved old Elounia conan-exiles-enhanced files out of the way. Refresh ADS templates to restore CubeCoders' official template."
  fi

  log "Old local file backup: $legacy_backup_dir"
}

restart_ads() {
  local owner_user="$1"
  local instance_name="$2"

  if command -v ampinstmgr >/dev/null 2>&1; then
    run_as_owner "$owner_user" ampinstmgr restart "$instance_name"
  elif [[ -x /opt/cubecoders/amp/ampinstmgr ]]; then
    run_as_owner "$owner_user" /opt/cubecoders/amp/ampinstmgr restart "$instance_name"
  else
    die "ampinstmgr was not found. Template installed, but ADS was not restarted."
  fi
}

validate_source

if [[ $DRY_RUN -eq 0 && ${EUID:-$(id -u)} -ne 0 ]]; then
  log "sudo is required to write into AMP's instance data. You should be prompted once."
  exec sudo -E bash "$0" "${ORIGINAL_ARGS[@]}"
fi

find_template_cache
ADS_NAME="$(ads_instance_name)"

log "Source template: $TEMPLATE_DIR"
log "Target AMP cache: $TEMPLATE_CACHE"
log "Target ADS instance: $ADS_NAME"

if [[ $DRY_RUN -eq 1 ]]; then
  log "Dry run only. No files copied and ADS was not restarted."
  exit 0
fi

OWNER_USER="$(stat -c '%U' "$TEMPLATE_CACHE")"
OWNER_GROUP="$(stat -c '%G' "$TEMPLATE_CACHE")"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
if [[ -n "${AMP_TEMPLATE_BACKUP_ROOT:-}" ]]; then
  BACKUP_ROOT="$AMP_TEMPLATE_BACKUP_ROOT"
elif [[ -d "$INSTANCES_ROOT/.." ]]; then
  BACKUP_ROOT="$(cd -- "$INSTANCES_ROOT/.." && pwd)/template-backups"
else
  BACKUP_ROOT="$(cd -- "$(dirname -- "$TEMPLATE_CACHE")" && pwd)/template-backups"
fi
BACKUP_DIR="$BACKUP_ROOT/$APP_ID/$TIMESTAMP"

if [[ $BACKUP -eq 1 ]]; then
  install -d -o "$OWNER_USER" -g "$OWNER_GROUP" -m 0755 "$BACKUP_DIR"
fi

for file in "${TEMPLATE_FILES[@]}"; do
  if [[ $BACKUP -eq 1 && -f "$TEMPLATE_CACHE/$file" ]]; then
    install -o "$OWNER_USER" -g "$OWNER_GROUP" -m 0644 "$TEMPLATE_CACHE/$file" "$BACKUP_DIR/$file"
  fi
  install -o "$OWNER_USER" -g "$OWNER_GROUP" -m 0644 "$TEMPLATE_DIR/$file" "$TEMPLATE_CACHE/$file"
done

cd "$TEMPLATE_CACHE"

restore_official_conan_template_if_overwritten "$OWNER_USER" "$OWNER_GROUP" "$BACKUP_ROOT" "$TIMESTAMP"

validate_template_set "$TEMPLATE_CACHE"

if [[ $COMMIT -eq 1 && -d .git ]] && command -v git >/dev/null 2>&1; then
  run_as_owner "$OWNER_USER" git config user.name "AMP Local Template Installer"
  run_as_owner "$OWNER_USER" git config user.email "amp-local@example.invalid"
  run_as_owner "$OWNER_USER" git add "${TEMPLATE_FILES[@]}" "${LEGACY_LOCAL_FILES[@]}"
  if ! run_as_owner "$OWNER_USER" git diff --cached --quiet; then
    run_as_owner "$OWNER_USER" git commit -m "Install Conan Exiles Enhancen Elounia template"
  else
    log "No template-cache git changes to commit."
  fi
fi

if [[ $RESTART_ADS -eq 1 ]]; then
  restart_ads "$OWNER_USER" "$ADS_NAME"
else
  log "ADS restart skipped. Restart ADS or refresh deployment templates before checking the dropdown."
fi

log "Installed. Create Instance should now include: $APP_NAME"
if [[ $BACKUP -eq 1 ]]; then
  log "Backup directory: $BACKUP_DIR"
fi
