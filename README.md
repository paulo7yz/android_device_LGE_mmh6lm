# TWRP device tree — LG X120 (LM-X120BMW) / mmh6lm / MT6739

Tree construída a partir de dados **reais** extraídos do aparelho via ADB (root Magisk),
não de estimativas. Confirmações que abatem erros do tree antigo:

| Item | Tree antiga | Dado real (ADB) |
|---|---|---|
| SoC | `mt6739` / `MT6737M` (misturados) | **MT6739** (`ro.board.platform=mt6739`) |
| Arch | `armv8-a` + `TARGET_IS_64_BIT=false` | **armv7-a-neon** (kernel e userspace 32-bit, `uname armv7l`) |
| Resolução | 720x1280 vs 480x960 | **480x960** (fb0 virtual 480x2880 = triple buffer) |
| fstab | chutes | **extraído de `/vendor/etc/fstab.mmh6lm`**: system ext4, userdata **f2fs + FBE aes-256-xts:cts**, cache ext4 |
| Kernel | "kernel/zImage" sem verificação | **extraído do stock recovery.img @0x800 (0x844076 bytes ≈8.67MB), kernel 4.4.146** |
| TWRP branch | twrp-11 | **twrp-9.0** (kernel 4.4 + 32-bit) |
| UDC | hardcoded | `musb-hdrc` (confirmado) |

## Estrutura

```
device-tree/device/lge/mmh6lm/
├── AndroidProducts.mk
├── twrp_mmh6lm.mk
├── BoardConfig.mk
├── kernel                      (zImage extraído do stock recovery.img)
└── recovery/root/etc/twrp.fstab
tools/repack_lg.py              (usa o container stock como base, sobrescreve só o ramdisk)
```

## Como funciona o build (CI)

1. `repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-9.0; repo sync -j8`
2. Copia device-tree acima para `device/lge/mmh6lm/`.
3. `source build/envsetup.sh; lunch twrp_mmh6lm-eng; make -j8 recoveryimage`
4. O AOSP gera o recovery.img pronto em  `out/target/product/mmh6lm/recovery.img` — NÃO
   é necessário usar repack_lg.py para esse caminho; o formatamento padrão do AOSP
   (mkbootimg) já produziu um recovery.img válido.
5. No CI, mode `runs-on: ubuntu-22.04` — o build do TWRP 9 roda bem.

O AOSP (TWRP 9) gera `recovery.img` via mkbootimg usando os offsets/pagesize do
BoardConfig (todos do dump real do stock).

## Flash / teste

```
# voltar pro recovery original em caso de brick: recoverybak é cópia do stock
adb reboot loader
fastboot flash recovery recovery.img
fastboot reboot recovery
```

Se LU não entrar: `fastboot reboot` + `adb reboot recovery`.
Rollback de emergência: existe a partição `recoverybak` = `recovery` original.
```
fastboot flash recovery recoverybak.img  # (dumpado de /dev/block/by-name/recoverybak)
```

| **CircleSpecs — o que foi feito** | |
|---|---|
| Propriedades coletadas | getprop completo (SoC, arch, painel, UDC, DDR, lkm) |
| Partição mapeada | /proc/partitions + by-name (boot=0p38, recovery=0p39, dtbo=0p41, vendor=0p48, system=0p49, etc.) |
| Kernel extraído | recovery.img @0x800 (0x844076 bytes ≈ 8.67MB, kernel 4.4.146) ✓ |
| fstab real | /vendor/etc/fstab.mmh6lm (system ext4, userdata f2fs+FBE, cache ext4) ✓ |
| fstab TWRP | device-tree/device/lge/mmh6lm/recovery/root/etc/twrp.fstab ✓ |
| BoardConfig | device-tree/device/lge/mmh6lm/BoardConfig.mk (values do real) ✓ |
| ramdisk / recovery.img | dump do tem "ramdisk em região criptografada/props LG-fake no header" — formato ainda não decodado; trabalhar com repack do stock (tools/repack_lg.py) |

## Confirmações do aparelho

- Bootloader: **unlocked** (`vbmeta.device_state=unlocked`) → flash livre.

- Bootloader: **unlocked** (`vbmeta.device_state=unlocked`) → flash livre.
- Painel: `LIDE-ST7701S` ST7701S
- RAM DDR: 1 GB (sg 1073741824)
- Cam: 8MP / 5MP front; fingerprint: **0** (não tem); dual SIM (dsds)
- Bootil: `rev_10`
- Android: 9 SDK 28
- build fingerprint: `lge/mmh6lm/mmh6lm:9/PKQ1.180904.001/6739900210901:user/release-keys`

## Notas

- FBE (File-Based Encryption) em um MTK FBE + TWRP 9: sem decrypt completo de /data;
  o manter isso é atrás de TW crypto f2fs.
  `TW_CRYPTO_FS_TYPE = f2fs` está setado;
- O tree não usa auto-descoberta via ADB. Os valores atuais foram constantes fixadas a
  partir do dump real. Rebuild do fstab apenas se mudar resposta do vendor fstab.
- O `ro.secure`/`ro.debuggable` (bypass do init hack de build antigo) não são usados aqui.
