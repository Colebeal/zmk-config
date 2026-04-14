# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A ZMK firmware configuration repo (`zmk-config`) for a **Corne (crkbd) wireless split keyboard** with **nice!nano v2** controllers (nRF52840). This is not the ZMK firmware itself — it's a user configuration layer that references upstream `zmkfirmware/zmk` via a west manifest.

## Repo Structure

```
config/
  corne.keymap   — devicetree keymap (layers, macros, behaviors)
  corne.conf     — Kconfig options (sleep, BT, RGB)
  west.yml       — west manifest pointing to upstream ZMK
build.yaml       — build matrix (nice_nano_v2 × corne_left/corne_right)
.github/workflows/build.yml — GitHub Actions CI that produces .uf2 artifacts
```

## Build & Flash Workflow

There is **no local build**. All builds happen via GitHub Actions:

1. Push changes to `main`
2. Actions builds two `.uf2` firmware files (left and right halves)
3. Download artifacts from the Actions run
4. Flash: connect half via USB → double-tap reset → drag `.uf2` onto mounted drive

Only the left half pairs to the host over Bluetooth.

## Keymap Architecture

The keymap (`config/corne.keymap`) uses devicetree syntax (`.dtsi` includes, `/` root node). Key concepts:

- **4 layers**: Default (QWERTY + home row mods), Lower (numbers/F-keys/arrows/media), Raise (symbols), Adjust (macros/gaming)
- **Home row mods**: `&mt` (mod-tap) on home row keys with `balanced` flavor, 200ms tapping-term, 150ms quick-tap, 125ms require-prior-idle
- **Macros**: `zmk,behavior-macro` nodes for Mac screenshot (`Cmd+Shift+4`) and `Alt+N` shortcuts
- **Layer access**: `&mo N` (momentary) on thumb keys; `&tog 3` toggles the Adjust layer

## ZMK-Specific Conventions

- Key codes use ZMK names (e.g., `LSHFT`, `LGUI`, `SQT`, `FSLH`) from `<dt-bindings/zmk/keys.h>`
- Bluetooth bindings come from `<dt-bindings/zmk/bt.h>`, RGB from `<dt-bindings/zmk/rgb.h>`
- Kconfig booleans in `.conf` use `CONFIG_*=y` / `CONFIG_*=n` syntax
- The Corne has a 6×3+3 layout per half (42 key positions in the bindings matrix, written as 12 columns × 3 rows + 3 thumb keys per side)

## Configuration Reference

**corne.conf** controls board-level features:
- `CONFIG_ZMK_SLEEP=y` + `CONFIG_ZMK_IDLE_SLEEP_TIMEOUT=900000` — deep sleep after 15 min idle
- `CONFIG_BT_CTLR_TX_PWR_PLUS_8=y` — max Bluetooth transmit power
- RGB underglow options are present but commented out
