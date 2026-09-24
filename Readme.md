# ESP32 Single Button — battery keyfob (XIAO C3 / C6)

ESPHome firmware for a **single-button**, battery-powered remote on the same core circuit as [ESPFob](../espfob): one switch, WS2812B RGB with MOSFET power gating, and switched battery divider for low idle drain.

## Pin map (D silkscreen)

| D pin | Function       | Notes                                |
| ----- | -------------- | ------------------------------------ |
| D0    | Battery sense  | 1:2 divider — multiply by 2 in YAML  |
| D1    | Button (SW1)   | Deep-sleep wake (RTC / LP on C3 / C6) |
| D6    | RGB data       | WS2812B                              |
| D9    | RGB power      | HIGH = LED powered                   |
| D10   | Divider power  | HIGH = battery measurement enabled   |

Button is active **low** (external 10k pull-up). On boot and each press, firmware briefly pulses the RGB LED, samples battery voltage, stays awake ~5s after each press (configurable via `awake_after_button_ms`), then deep sleeps until the next press.

## Files

| File               | Target                    |
| ------------------ | ------------------------- |
| `esphome-common.yaml` | Shared hardware / logic |
| `esphome-c6.yaml`  | Seeed XIAO **ESP32-C6**   |
| `esphome-c3.yaml`  | Seeed XIAO **ESP32-C3**   |

## Build and flash

```bash
make setup
make config-c6
make flash-c6
```

Factory images after `make build`: `firmware-c6.bin`, `firmware-c3.bin`.

Provisioning: Improv (BLE + serial) and captive portal fallback, same pattern as ESPFob.

## Home Assistant

Add the device via ESPHome Dashboard (open `esphome-c6.yaml` or clone this repo). Automate on the **Button** binary sensor entity.
