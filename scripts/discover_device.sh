#!/sbin/sh
# =============================================================================
# discover_device.sh - Auto-descoberta de parâmetros de hardware via ADB
# Projeto: TWRP para LG K8+ (LM-X120BMW) - MT6737M (32-bit ARM)
# =============================================================================
# Conecta via adb devices, aguarda o dispositivo, extrai propriedades
# de hardware e gera device_vars.mk + device_vars.env para uso no build
# dinâmico do TWRP.
#
# Saída:
#   - device_vars.mk   (sintaxe Makefile, incluído por BoardConfig.mk)
#   - device_vars.env   (sintaxe shell, para uso no CI)
#
# Exit codes:
#   0 - sucesso, arquivos gerados
#   1 - dispositivo não encontrado (deixa CI chamar fallback_vars.sh)
#   2 - erro de runtime (adb indisponível, permissão negada, etc.)
# =============================================================================

set -eu

# ---------------------------------------------------------------------------
# Configuração
# ---------------------------------------------------------------------------
ADB_TIMEOUT=60          # segundos aguardando dispositivo
ADB_POLL_INTERVAL=2     # intervalo entre tentativas
OUTPUT_MK="device_vars.mk"
OUTPUT_ENV="device_vars.env"

# Prefixo de log
log()  { echo "[DISCOVER] $*" >&2; }
err()  { echo "[DISCOVER][ERROR] $*" >&2; }
warn() { echo "[DISCOVER][WARN] $*" >&2; }

# ---------------------------------------------------------------------------
# Verificações iniciais
# ---------------------------------------------------------------------------
if ! command -v adb >/dev/null 2>&1; then
    err "adb não encontrado no PATH. Instale o platform-tools do Android SDK."
    exit 2
fi

# ---------------------------------------------------------------------------
# Aguarda dispositivo ADB
# ---------------------------------------------------------------------------
log "Aguardando dispositivo ADB (timeout ${ADB_TIMEOUT}s)..."

elapsed=0
device_serial=""
while [ "${elapsed}" -lt "${ADB_TIMEOUT}" ]; do
    # adb devices retorna linhas no formato "<serial>\tdevice" ou "<serial>\tunauthorized"
    device_serial=$(adb devices 2>/dev/null | awk 'NR>1 && $2=="device" {print $1; exit}')
    if [ -n "${device_serial}" ]; then
        log "Dispositivo conectado: ${device_serial}"
        break
    fi
    # Verifica se há dispositivo não autorizado
    unauthorized=$(adb devices 2>/dev/null | awk 'NR>1 && $2=="unauthorized" {print $1; exit}')
    if [ -n "${unauthorized}" ]; then
        warn "Dispositivo detectado mas NÃO autorizado: ${unauthorized}"
        warn "Aceite a depuração RSA na tela do dispositivo."
    fi
    sleep "${ADB_POLL_INTERVAL}"
    elapsed=$((elapsed + ADB_POLL_INTERVAL))
done

if [ -z "${device_serial}" ]; then
    err "Nenhum dispositivo ADB encontrado após ${ADB_TIMEOUT}s."
    err "Execute scripts/fallback_vars.sh para usar valores estimados."
    exit 1
fi

# ---------------------------------------------------------------------------
# Extrai propriedades via getprop
# ---------------------------------------------------------------------------
log "Extraindo propriedades via adb shell getprop..."

get_prop() {
    adb shell getprop "$1" 2>/dev/null | tr -d '\r\n'
}

RO_HARDWARE=$(get_prop ro.hardware)
RO_PRODUCT_DEVICE=$(get_prop ro.product.device)
RO_SERIALNO=$(get_prop ro.serialno)
RO_BOOT_MODE=$(get_prop ro.boot.mode)
RO_BOARD_PLATFORM=$(get_prop ro.board.platform)
RO_PRODUCT_CPU_ABI=$(get_prop ro.product.cpu.abi)
RO_PRODUCT_MODEL=$(get_prop ro.product.model)
RO_BUILD_ID=$(get_prop ro.build.id)

log "  ro.hardware        = ${RO_HARDWARE}"
log "  ro.product.device  = ${RO_PRODUCT_DEVICE}"
log "  ro.serialno        = ${RO_SERIALNO}"
log "  ro.boot.mode       = ${RO_BOOT_MODE}"
log "  ro.board.platform  = ${RO_BOARD_PLATFORM}"
log "  ro.product.cpu.abi = ${RO_PRODUCT_CPU_ABI}"
log "  ro.product.model   = ${RO_PRODUCT_MODEL}"
log "  ro.build.id        = ${RO_BUILD_ID}"

# ---------------------------------------------------------------------------
# Obtém resolução do framebuffer
# ---------------------------------------------------------------------------
log "Obtendo resolução do framebuffer..."

SCREEN_WIDTH=""
SCREEN_HEIGHT=""

# Método 1: /sys/class/graphics/fb0/virtual_size (formato "720,1280")
fb_vsize=$(adb shell cat /sys/class/graphics/fb0/virtual_size 2>/dev/null | tr -d '\r\n')
if [ -n "${fb_vsize}" ]; then
    log "  fb0/virtual_size = ${fb_vsize}"
    SCREEN_WIDTH=$(echo "${fb_vsize}" | cut -d',' -f1 | tr -d ' ')
    SCREEN_HEIGHT=$(echo "${fb_vsize}" | cut -d',' -f2 | tr -d ' ')
fi

# Método 2: /sys/class/graphics/fb0/modes (algumas plataformas)
if [ -z "${SCREEN_WIDTH}" ] || [ -z "${SCREEN_HEIGHT}" ]; then
    fb_modes=$(adb shell cat /sys/class/graphics/fb0/modes 2>/dev/null | tr -d '\r\n')
    if [ -n "${fb_modes}" ]; then
        log "  fb0/modes = ${fb_modes}"
        # Formato típico: "U:720x1280p-0" ou "720x1280"
        parsed=$(echo "${fb_modes}" | grep -oE '[0-9]+x[0-9]+' | head -1)
        if [ -n "${parsed}" ]; then
            SCREEN_WIDTH=$(echo "${parsed}" | cut -d'x' -f1)
            SCREEN_HEIGHT=$(echo "${parsed}" | cut -d'x' -f2)
        fi
    fi
fi

# Método 3: dumpsys display filtrando mBaseDisplayInfo
if [ -z "${SCREEN_WIDTH}" ] || [ -z "${SCREEN_HEIGHT}" ]; then
    log "  Fallback: dumpsys display | mBaseDisplayInfo"
    display_info=$(adb shell dumpsys display 2>/dev/null | grep mBaseDisplayInfo | head -1 | tr -d '\r')
    if [ -n "${display_info}" ]; then
        log "  mBaseDisplayInfo = ${display_info}"
        # Procura padrão "WxH" ou "W x H"
        parsed=$(echo "${display_info}" | grep -oE '[0-9]+x[0-9]+' | head -1)
        if [ -n "${parsed}" ]; then
            SCREEN_WIDTH=$(echo "${parsed}" | cut -d'x' -f1)
            SCREEN_HEIGHT=$(echo "${parsed}" | cut -d'x' -f2)
        fi
    fi
fi

# Método 4: wm size (Android 4.3+)
if [ -z "${SCREEN_WIDTH}" ] || [ -z "${SCREEN_HEIGHT}" ]; then
    wm_size=$(adb shell wm size 2>/dev/null | tr -d '\r\n')
    if [ -n "${wm_size}" ]; then
        log "  wm size = ${wm_size}"
        parsed=$(echo "${wm_size}" | grep -oE '[0-9]+x[0-9]+' | head -1)
        if [ -n "${parsed}" ]; then
            SCREEN_WIDTH=$(echo "${parsed}" | cut -d'x' -f1)
            SCREEN_HEIGHT=$(echo "${parsed}" | cut -d'x' -f2)
        fi
    fi
fi

if [ -z "${SCREEN_WIDTH}" ] || [ -z "${SCREEN_HEIGHT}" ]; then
    warn "Não foi possível obter resolução. Usando fallback 480x960."
    SCREEN_WIDTH=480
    SCREEN_HEIGHT=960
fi

log "  Resolução final: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"

# ---------------------------------------------------------------------------
# Descobre caminho do brilho
# ---------------------------------------------------------------------------
log "Descobrindo caminho do brilho..."

BRIGHTNESS_PATH=$(adb shell 'find /sys/class/leds/ -name "brightness" 2>/dev/null | grep -i "lcd\|backlight\|panel" | head -1' 2>/dev/null | tr -d '\r\n')
if [ -z "${BRIGHTNESS_PATH}" ]; then
    BRIGHTNESS_PATH=$(adb shell 'find /sys/class/leds/ -name "brightness" 2>/dev/null | head -1' 2>/dev/null | tr -d '\r\n')
fi

if [ -z "${BRIGHTNESS_PATH}" ]; then
    warn "Caminho de brilho não encontrado. Usando fallback."
    BRIGHTNESS_PATH="/sys/class/leds/lcd-backlight/brightness"
fi

log "  BRIGHTNESS_PATH = ${BRIGHTNESS_PATH}"

# max_brightness
BRIGHTNESS_DIR=$(dirname "${BRIGHTNESS_PATH}")
MAX_BRIGHTNESS=$(adb shell "cat ${BRIGHTNESS_DIR}/max_brightness 2>/dev/null" 2>/dev/null | tr -d '\r\n')
if [ -z "${MAX_BRIGHTNESS}" ]; then
    warn "max_brightness não encontrado. Usando 255."
    MAX_BRIGHTNESS=255
fi
log "  MAX_BRIGHTNESS = ${MAX_BRIGHTNESS}"

# ---------------------------------------------------------------------------
# Descobre nome do controlador USB (UDC)
# ---------------------------------------------------------------------------
log "Descobrindo controlador USB (UDC)..."

USB_UDC_NAME=$(adb shell 'ls /sys/class/udc/ 2>/dev/null | head -1' 2>/dev/null | tr -d '\r\n')
if [ -z "${USB_UDC_NAME}" ]; then
    warn "UDC não encontrado em /sys/class/udc/. Usando fallback musb-hdrc."
    USB_UDC_NAME="musb-hdrc"
fi
log "  USB_UDC_NAME = ${USB_UDC_NAME}"

# ---------------------------------------------------------------------------
# Descobre dispositivos de input (touchscreen)
# ---------------------------------------------------------------------------
log "Descobrindo dispositivos de input..."

INPUT_DEVICES=$(adb shell 'ls /dev/input/ 2>/dev/null' 2>/dev/null | tr -d '\r' | tr '\n' ' ')
log "  INPUT_DEVICES = ${INPUT_DEVICES}"

# Touchscreen específico
TOUCHSCREEN_PATH=$(adb shell 'find /sys/class/input/ -name "name" 2>/dev/null | xargs grep -li "touch" 2>/dev/null | head -1' 2>/dev/null | tr -d '\r\n')
log "  TOUCHSCREEN = ${TOUCHSCREEN_PATH}"

# ---------------------------------------------------------------------------
# Descobre partições (para recovery.fstab)
# ---------------------------------------------------------------------------
log "Descobrindo partições..."

BOOT_DEVICE=$(adb shell 'readlink /dev/block/by-name/boot 2>/dev/null || readlink /dev/block/platform/*/by-name/boot 2>/dev/null' 2>/dev/null | tr -d '\r\n')
RECOVERY_DEVICE=$(adb shell 'readlink /dev/block/by-name/recovery 2>/dev/null || readlink /dev/block/platform/*/by-name/recovery 2>/dev/null' 2>/dev/null | tr -d '\r\n')
SYSTEM_DEVICE=$(adb shell 'readlink /dev/block/by-name/system 2>/dev/null || readlink /dev/block/platform/*/by-name/system 2>/dev/null' 2>/dev/null | tr -d '\r\n')
DATA_DEVICE=$(adb shell 'readlink /dev/block/by-name/userdata 2>/dev/null || readlink /dev/block/platform/*/by-name/userdata 2>/dev/null' 2>/dev/null | tr -d '\r\n')

log "  boot     = ${BOOT_DEVICE}"
log "  recovery = ${RECOVERY_DEVICE}"
log "  system   = ${SYSTEM_DEVICE}"
log "  userdata = ${DATA_DEVICE}"

# ---------------------------------------------------------------------------
# Gera device_vars.mk (sintaxe Makefile)
# ---------------------------------------------------------------------------
log "Gerando ${OUTPUT_MK}..."

cat > "${OUTPUT_MK}" << EOF_MK
# =============================================================================
# device_vars.mk - Auto-gerado por discover_device.sh - NÃO EDITAR MANUALMENTE
# Dispositivo: ${RO_PRODUCT_MODEL} (${RO_PRODUCT_DEVICE})
# Serial: ${RO_SERIALNO}
# Gerado em: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
# =============================================================================

# --- Propriedades do dispositivo ---
RO_HARDWARE := ${RO_HARDWARE}
RO_PRODUCT_DEVICE := ${RO_PRODUCT_DEVICE}
RO_SERIALNO := ${RO_SERIALNO}
RO_BOOT_MODE := ${RO_BOOT_MODE}
RO_BOARD_PLATFORM := ${RO_BOARD_PLATFORM}
RO_PRODUCT_CPU_ABI := ${RO_PRODUCT_CPU_ABI}
RO_PRODUCT_MODEL := ${RO_PRODUCT_MODEL}
RO_BUILD_ID := ${RO_BUILD_ID}

# --- Tela / Framebuffer ---
TARGET_SCREEN_WIDTH := ${SCREEN_WIDTH}
TARGET_SCREEN_HEIGHT := ${SCREEN_HEIGHT}

# --- Brilho ---
TW_BRIGHTNESS_PATH := "${BRIGHTNESS_PATH}"
TW_MAX_BRIGHTNESS := ${MAX_BRIGHTNESS}

# --- USB / UDC ---
USB_UDC_NAME := "${USB_UDC_NAME}"

# --- Input ---
TW_INPUT_DEVICE := "${INPUT_DEVICES}"

# --- Partições ---
BOARD_BOOTIMAGE_PARTITION_DEVICE := "${BOOT_DEVICE}"
BOARD_RECOVERYIMAGE_PARTITION_DEVICE := "${RECOVERY_DEVICE}"
BOARD_SYSTEMIMAGE_PARTITION_DEVICE := "${SYSTEM_DEVICE}"
BOARD_USERDATAIMAGE_PARTITION_DEVICE := "${DATA_DEVICE}"
EOF_MK

log "  ${OUTPUT_MK} gerado ($(wc -l < "${OUTPUT_MK}") linhas)"

# ---------------------------------------------------------------------------
# Gera device_vars.env (sintaxe shell, para CI)
# ---------------------------------------------------------------------------
log "Gerando ${OUTPUT_ENV}..."

cat > "${OUTPUT_ENV}" << EOF_ENV
# =============================================================================
# device_vars.env - Auto-gerado por discover_device.sh - NÃO EDITAR MANUALMENTE
# Dispositivo: ${RO_PRODUCT_MODEL} (${RO_PRODUCT_DEVICE})
# Serial: ${RO_SERIALNO}
# Gerado em: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
# =============================================================================

export RO_HARDWARE="${RO_HARDWARE}"
export RO_PRODUCT_DEVICE="${RO_PRODUCT_DEVICE}"
export RO_SERIALNO="${RO_SERIALNO}"
export RO_BOOT_MODE="${RO_BOOT_MODE}"
export RO_BOARD_PLATFORM="${RO_BOARD_PLATFORM}"
export RO_PRODUCT_CPU_ABI="${RO_PRODUCT_CPU_ABI}"
export RO_PRODUCT_MODEL="${RO_PRODUCT_MODEL}"
export RO_BUILD_ID="${RO_BUILD_ID}"

export TARGET_SCREEN_WIDTH=${SCREEN_WIDTH}
export TARGET_SCREEN_HEIGHT=${SCREEN_HEIGHT}

export TW_BRIGHTNESS_PATH="${BRIGHTNESS_PATH}"
export TW_MAX_BRIGHTNESS=${MAX_BRIGHTNESS}

export USB_UDC_NAME="${USB_UDC_NAME}"

export TW_INPUT_DEVICE="${INPUT_DEVICES}"

export BOARD_BOOTIMAGE_PARTITION_DEVICE="${BOOT_DEVICE}"
export BOARD_RECOVERYIMAGE_PARTITION_DEVICE="${RECOVERY_DEVICE}"
export BOARD_SYSTEMIMAGE_PARTITION_DEVICE="${SYSTEM_DEVICE}"
export BOARD_USERDATAIMAGE_PARTITION_DEVICE="${DATA_DEVICE}"
EOF_ENV

log "  ${OUTPUT_ENV} gerado ($(wc -l < "${OUTPUT_ENV}") linhas)"

# ---------------------------------------------------------------------------
# Resumo final
# ---------------------------------------------------------------------------
log "========================================"
log "Auto-descoberta CONCLUÍDA com sucesso."
log "  Dispositivo: ${RO_PRODUCT_MODEL} (${RO_PRODUCT_DEVICE})"
log "  SoC: ${RO_BOARD_PLATFORM} (${RO_PRODUCT_CPU_ABI})"
log "  Tela: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
log "  UDC: ${USB_UDC_NAME}"
log "  Brilho: ${BRIGHTNESS_PATH} (max=${MAX_BRIGHTNESS})"
log "========================================"

exit 0
