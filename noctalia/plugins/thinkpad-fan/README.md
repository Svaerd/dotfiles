# Noctalia Fan & Thermal Control Plugin (`thinkpad-fan`)

A resilient system utility plugin designed for the **Noctalia** desktop shell environment. It monitors embedded system temperatures and maps hardware overrides to manual fan speeds directly through secure sysfs platform pathways without escalation prompts.

## Features
--------

*   **Dynamic Fan Speed Indicator**: Embedded status bar module reporting realtime revolutions per minute (`RPM`) telemetry, updating cycles safely every 2 seconds.
*   **Thermal Zone Inspector**: Contextual diagnostic popup panel tracking active primary sensor clusters.
*   **Stateful Micro-Pill Alerts**: The bar capsule color-shifts based on the current fan mode (when *Dynamic coloring* is enabled):
    *   **Fan off (`level 0`)**: uses the configurable *Fan off* color (defaults to the theme `mError`).
    *   **Automatic mode**: neutral by default, matching the rest of the bar — optionally a custom *Automatic mode* color can be chosen.
    *   **Any forced speed** (levels `1`–`7`, full speed, …): uses the configurable *Fan active* color (defaults to the theme `mPrimary`).
*   **Configurable Colors**: The *Fan off*, *Fan active* and *Automatic mode* colors are pickable from the theme palette in the plugin settings — each can also be set to **neutral** (no color) to match the bar.

## Settings
--------

Open the plugin settings (right-click the widget → **Widget Settings**) to configure:

*   **Dynamic coloring**: toggle the mode-based capsule coloring on/off. When off, the capsule keeps the default bar color.
    *   **Fan off color**: palette color used when the fan is stopped (`level 0`).
    *   **Fan active color**: palette color used whenever the fan runs at a forced speed (every mode except automatic and off).
    *   **Automatic mode color**: palette color for automatic mode (neutral by default).
    *   Each of the three pickers includes a **neutral** (no-color) option as the first swatch — choose it to keep that mode matching the bar.
*   **Fan speed manual override**: when enabled, left-clicking the widget opens the manual fan control panel.

## Prerequisites
-------------

1.  **ACPI Drivers**: Ensure driver hooks are mapped correctly (e.g., `thinkpad_acpi` loaded with control permission flags allowed: `options thinkpad_acpi fan_control=1`).
2.  **Udev Mapping Rules**: Write permissions are required to execute adjustments inside `/proc/acpi/ibm/fan` without utilizing full root escalation pipelines.

## Installation and Setup
----------------------

### 1\. Run Local Security Mapping Adjustments

Grant group write parameters over systemic thermal interfaces by applying the setup script:

    cd ~/.config/noctalia/plugins/thinkpad-fan/
    chmod +x setup_permissions.sh
    ./setup_permissions.sh

### 2\. Session Reset

Log out of your graphical target environment session completely to ensure the hardware communication group attachments lock successfully into place before restarting your window manager layout.