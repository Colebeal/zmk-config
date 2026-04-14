# ZMK Config Setup Brief — Corne Wireless (Bluetooth)

## Goal
Set up a `zmk-config` GitHub repo that builds firmware for a **Corne (crkbd) wireless split keyboard** with **nice!nano v2** controllers. Push to GitHub so Actions builds two `.uf2` files (left + right halves).

## Repo Structure
```
zmk-config/
├── config/
│   ├── corne.keymap      ← keymap file (provided below)
│   ├── corne.conf        ← board config (generate this)
│   └── west.yml          ← ZMK west manifest
├── build.yaml            ← GitHub Actions build matrix
└── .github/
    └── workflows/
        └── build.yml     ← ZMK build workflow
```

## build.yaml (build matrix)
```yaml
include:
  - board: nice_nano_v2
    shield: corne_left
  - board: nice_nano_v2
    shield: corne_right
```

## corne.conf
```conf
# Enable deep sleep (saves battery)
CONFIG_ZMK_SLEEP=y
CONFIG_ZMK_IDLE_SLEEP_TIMEOUT=900000

# Bluetooth
CONFIG_BT_CTLR_TX_PWR_PLUS_8=y

# Uncomment if board has RGB LEDs
# CONFIG_ZMK_RGB_UNDERGLOW=y
# CONFIG_WS2812_STRIP=y
```

## corne.keymap

```dts
/*
 * Corne Wireless ZMK Keymap
 * Converted from Unicorne VIA layout
 *
 * Layer 0: Default (QWERTY + home row mods)
 * Layer 1: Lower (numbers, F-keys, arrows, media)
 * Layer 2: Raise (symbols)
 * Layer 3: Adjust (macros / gaming-ish layer)
 */

#include <behaviors.dtsi>
#include <dt-bindings/zmk/keys.h>
#include <dt-bindings/zmk/bt.h>
#include <dt-bindings/zmk/rgb.h>

/ {
    macros {
        mac_ss: mac_ss {
            compatible = "zmk,behavior-macro";
            #binding-cells = <0>;
            bindings = <&kp LG(LS(N4))>;
        };
        alt_1: alt_1 {
            compatible = "zmk,behavior-macro";
            #binding-cells = <0>;
            bindings = <&kp LA(N1)>;
        };
        alt_2: alt_2 {
            compatible = "zmk,behavior-macro";
            #binding-cells = <0>;
            bindings = <&kp LA(N2)>;
        };
        alt_3: alt_3 {
            compatible = "zmk,behavior-macro";
            #binding-cells = <0>;
            bindings = <&kp LA(N3)>;
        };
        alt_4: alt_4 {
            compatible = "zmk,behavior-macro";
            #binding-cells = <0>;
            bindings = <&kp LA(N4)>;
        };
        alt_5: alt_5 {
            compatible = "zmk,behavior-macro";
            #binding-cells = <0>;
            bindings = <&kp LA(N5)>;
        };
        alt_6: alt_6 {
            compatible = "zmk,behavior-macro";
            #binding-cells = <0>;
            bindings = <&kp LA(N6)>;
        };
    };

    behaviors {
        mt: mod_tap {
            compatible = "zmk,behavior-hold-tap";
            #binding-cells = <2>;
            flavor = "balanced";
            tapping-term-ms = <200>;
            quick-tap-ms = <150>;
            require-prior-idle-ms = <125>;
            bindings = <&kp>, <&kp>;
        };
    };

    keymap {
        compatible = "zmk,keymap";

        default_layer {
            bindings = <
                &kp TAB    &kp Q       &kp W       &kp E       &kp R       &kp T           &kp Y   &kp U       &kp I       &kp O       &kp P          &kp BSPC
                &kp LALT   &mt LSHFT A &mt LCTRL S &mt LGUI D  &mt LALT F  &kp G           &kp H   &mt RALT J  &mt RGUI K  &mt RCTRL L &mt RSHFT SEMI &kp SQT
                &kp LSHFT  &kp Z       &kp X       &kp C       &kp V       &kp B           &kp N   &kp M       &kp COMMA   &kp DOT     &kp FSLH       &kp RSHFT
                                                    &mo 3       &mo 1       &kp SPACE       &kp RET &mo 2       &mo 3
            >;
        };

        lower_layer {
            bindings = <
                &kp ESC     &kp N1  &kp N2  &kp N3       &kp N4       &kp N5              &kp N6          &kp N7          &kp N8          &kp N9          &kp N0          &kp DEL
                &kp LCTRL   &kp F12 &kp F2  &kp C_VOL_DN &kp C_VOL_UP &kp C_PP            &kp LEFT        &kp DOWN        &kp UP          &kp RIGHT       &none           &rgb_ug RGB_BRI
                &mac_ss     &kp F1  &kp F2  &kp F3       &kp F4       &none               &rgb_ug RGB_EFF &rgb_ug RGB_HUD &rgb_ug RGB_HUI &rgb_ug RGB_SAD &rgb_ug RGB_SAI &rgb_ug RGB_BRD
                                            &kp LGUI     &trans       &trans              &trans          &trans          &kp RALT
            >;
        };

        raise_layer {
            bindings = <
                &kp TAB    &kp EXCL  &kp AT    &kp HASH  &kp DLLR  &kp PRCNT       &kp CARET &kp AMPS  &kp ASTRK &kp GRAVE &kp TILDE &kp DEL
                &kp LCTRL  &kp SQT   &kp LBKT  &kp LBRC  &kp LPAR  &trans          &kp FSLH  &kp MINUS &kp EQUAL &kp COLON &kp SEMI  &trans
                &trans     &kp DQT   &kp RBKT  &kp RBRC  &kp RPAR  &trans          &kp BSLH  &kp UNDER &kp PLUS  &kp PIPE  &kp QMARK &kp RSHFT
                                               &trans    &trans    &trans          &trans    &trans    &trans
            >;
        };

        adjust_layer {
            bindings = <
                &kp TAB    &alt_1  &alt_2  &alt_3  &alt_4  &alt_5          &alt_6  &kp U   &kp I     &kp O   &kp P     &kp BSPC
                &kp LCTRL  &kp A   &kp S   &kp D   &kp F   &kp G           &kp H   &kp J   &kp RALT  &kp L   &kp SEMI  &kp SQT
                &kp LSHFT  &kp Z   &kp X   &kp C   &kp V   &kp B           &kp N   &kp M   &kp COMMA &kp DOT &kp FSLH  &kp ESC
                                           &tog 3  &kp N4  &kp SPACE       &kp RET &mo 2   &mo 3
            >;
        };
    };
};
```

## Steps

1. Create a new GitHub repo called `zmk-config` under `Colebeal`
2. Use the ZMK GitHub Actions workflow from `zmkfirmware/unified-zmk-config-template` as reference
3. Place all files in the structure above
4. Push to `main` branch
5. Verify GitHub Actions triggers and builds two `.uf2` artifacts

## Flashing Instructions (for reference)
- Connect left half via USB → double-tap reset → drag `corne_left-nice_nano_v2-zmk.uf2` onto the mounted drive
- Repeat for right half with `corne_right-nice_nano_v2-zmk.uf2`
- Only the left half pairs to the Mac over Bluetooth
