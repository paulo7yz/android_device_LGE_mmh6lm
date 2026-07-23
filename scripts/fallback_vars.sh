#!/sbin/sh
# =============================================================================
# fallback_vars.sh - Variáveis de fallback para build do TWRP
# Projeto: TWRP para LG K8+ (LM-X120BMW) - MT6737M (32-bit ARM)
# =============================================================================
# Executado quando discover_device.sh falha (nenhum dispositivo ADB
# conectado ao runner). Define valores hardcoded baseados em MT6737M
# genérico e emite alertas no log, SEM interromper o build.
#
# Saída:
#   - device_vars.mk   (sintaxe Makefile)
#   - device_vars.env   (sintaxe shell)
#
# Exit codes:
#   0 - sempre (não interrompe o build)
# =============================================================================

set -u

OUTPUT_MK="device_vars.mk"
OUTPUT_ENV="device_vars.env"

# Prefixo de log
log()  { echo "[FALLBACK] $*" >&2; }
warn() { echo "[FALLBACK][WARN] $*" >&2; }

# ---------------------------------------------------------------------------
# Valores hardcoded - LG K8+ (LM-X120BMW) / MT6737M
# Baseados em documentação pública e builds anteriores da comunidade.
# ---------------------------------------------------------------------------
RO_HARDWARE="mmh6lm"
RO_PRODUCT_DEVICE="mmh6lm"
RO_SERIALNO="unknown"
RO_BOOT_MODE="unknown"
RO_BOARD_PLATFORM="mt6737m"
RO_PRODUCT_CPU_ABI="armeabi-v7a"
RO_PRODUCT_MODEL="LM-X120BMW"
RO_BUILD_ID="unknown"

SCREEN_WIDTH=720
SCREEN_HEIGHT=1280

BRIGHTNESS_PATH="/sys/class/leds/lcd-backlight/brightness"
MAX_BRIGHTNESS=255

USB_UDC_NAME="musb-hdrc"

INPUT_DEVICES="event0 event1 event2"

BOOT_DEVICE=""
RECOVERY_DEVICE=""
SYSTEM_DEVICE=""
DATA_DEVICE=""

# ---------------------------------------------------------------------------
# Alertas
# ---------------------------------------------------------------------------
warn "============================================================"
warn "MODO FALLBACK ATIVADO - Nenhum dispositivo ADB conectado."
warn "Usando valores hardcoded baseados em MT6737M genérico / LG K8+."
warn "Estes valores são ESTIMADOS e podem precisar de ajuste manual."
warn "============================================================"
warn ""
warn "Parâmetros estimados:"
warn "  ro.hardware        = ${RO_HARDWARE} (codinome LG - pode variar)"
warn "  ro.product.device  = ${RO_PRODUCT_DEVICE}"
warn "  ro.board.platform = ${RO_BOARD_PLATFORM}"
warn "  ro.product.cpu.abi = ${RO_PRODUCT_CPU_ABI}"
warn "  Resolução          = ${SCREEN_WIDTH}x${SCREEN_HEIGHT} (padrão LG K8+)"
warn "  Brilho             = ${BRIGHTNESS_PATH} (genérico MediaTek)"
warn "  UDC                = ${USB_UDC_NAME} (MediaTek musb-hdrc padrão)"
warn ""
warn "RECOMENDAÇÃO: Conecte um dispositivo real via ADB e execute"
warn "scripts/discover_device.sh para obter valores precisos."
warn "Se a UI do TWRP não desenhar ou ADB não aparecer, verifique:"
warn "  1. USB_UDC_NAME - pode ser 'musb-hdrc.0' em algumas revisões"
warn "  2. BRIGHTNESS_PATH - pode ser 'lcd-backlight' ou 'panel-backlight'"
warn "  3. Resolução - confirme via /sys/class/graphics/fb0/virtual_size"
warn ""

log "Gerando ${OUTPUT_MK} com valores de fallback..."

# ---------------------------------------------------------------------------
# Gera device_vars.mk (sintaxe Makefile)
# ---------------------------------------------------------------------------
cat > "${OUTPUT_MK}" << EOF_MK
# =============================================================================
# device_vars.mk - Gerado por fallback_vars.sh (MODO FALLBACK)
# Dispositivo: ${RO_PRODUCT_MODEL} (${RO_PRODUCT_DEVICE})
# AVISO: Valores estimados - sem dispositivo ADB conectado ao build.
# Gerado em: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
# =============================================================================

# --- Propriedades do dispositivo (FALLBACK) ---
RO_HARDWARE := ${RO_HARDWARE}
RO_PRODUCT_DEVICE := ${RO_PRODUCT_DEVICE}
RO_SERIALNO := ${RO_SERIALNO}
RO_BOOT_MODE := ${RO_BOOT_MODE}
RO_BOARD_PLATFORM := ${RO_BOARD_PLATFORM}
RO_PRODUCT_CPU_ABI := ${RO_PRODUCT_CPU_ABI}
RO_PRODUCT_MODEL := ${RO_PRODUCT_MODEL}
RO_BUILD_ID := ${RO_BUILD_ID}

# --- Tela / Framebuffer (FALLBACK: 720x1280 padrão LG K8+) ---
TARGET_SCREEN_WIDTH := ${SCREEN_WIDTH}
TARGET_SCREEN_HEIGHT := ${SCREEN_HEIGHT}

# --- Brilho (FALLBACK: genérico MediaTek) ---
TW_BRIGHTNESS_PATH := "${BRIGHTNESS_PATH}"
TW_MAX_BRIGHTNESS := ${MAX_BRIGHTNESS}

# --- USB / UDC (FALLBACK: musb-hdrc padrão MediaTek) ---
USB_UDC_NAME := "${USB_UDC_NAME}"

# --- Input (FALLBACK) ---
TW_INPUT_DEVICE := "${INPUT_DEVICES}"

# --- Partições (FALLBACK: vazio - preencher manualmente se necessário) ---
BOARD_BOOTIMAGE_PARTITION_DEVICE := "${BOOT_DEVICE}"
BOARD_RECOVERYIMAGE_PARTITION_DEVICE := "${RECOVERY_DEVICE}"
BOARD_SYSTEMIMAGE_PARTITION_DEVICE := "${SYSTEM_DEVICE}"
BOARD_USERDATAIMAGE_PARTITION_DEVICE := "${DATA_DEVICE}"
EOF_MK

log "  ${OUTPUT_MK} gerado ($(wc -l < "${OUTPUT_MK}" 2>/dev/null || echo '?') linhas)"

# ---------------------------------------------------------------------------
# Gera device_vars.env (sintaxe shell)
# ---------------------------------------------------------------------------
log "Gerando ${OUTPUT_ENV} com valores de fallback..."

cat > "${OUTPUT_ENV}" << EOF_ENV
# =============================================================================
# device_vars.env - Gerado por fallback_vars.sh (MODO FALLBACK)
# Dispositivo: ${RO_PRODUCT_MODEL} (${RO_PRODUCT_DEVICE})
# AVISO: Valores estimados - sem dispositivo ADB conectado ao build.
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

log "  ${OUTPUT_ENV} gerado"

# ---------------------------------------------------------------------------
# Resumo
# ---------------------------------------------------------------------------
log "========================================"
log "Fallback CONCLUÍDO. Build continuará com valores estimados."
log "  Dispositivo: ${RO_PRODUCT_MODEL} (${RO_PRODUCT_DEVICE})"
log "  SoC: ${RO_BOARD_PLATFORM} (${RO_PRODUCT_CPU_ABI})"
log "  Tela: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
log "  UDC: ${USB_UDC_NAME}"
log "  Brilho: ${BRIGHTNESS_PATH} (max=${MAX_BRIGHTNESS})"
log "========================================"

# Sempre exit 0 - não interrompe o build
exit 0
