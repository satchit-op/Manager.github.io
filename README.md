# RideGuard — 3D Model Package

Mini bike-mounted SOS device: detects a fall, sends **GPS location by SMS** to an
emergency number over a GSM/SIM module, with a **cancel button** to abort false alerts.

## Contents

| File | What it is |
|---|---|
| `rideguard.scad` | Parametric OpenSCAD model — all printable parts |
| `rideguard-viewer.html` | Interactive 3D viewer (open in any browser) |

## Interactive viewer

Open `rideguard-viewer.html` in Chrome/Edge/Firefox (needs internet once, for the
Three.js CDN). Controls:

- **Exploded view** — animates shell, PCB, battery and lid apart to show internals
- **Auto-rotate / Labels** — presentation toggles
- **Save PNG** — exports the current frame (great for your report or a video still)
- Drag to orbit, scroll to zoom, right-drag to pan

Tip: screen-record the explode animation while narrating the parts — it fits
perfectly in the 0:15–0:30 segment of your pitch.

## Printing (OpenSCAD)

1. Install [OpenSCAD](https://openscad.org), open `rideguard.scad`
2. Pick a part in the `part` dropdown: `shell`, `lid`, `button`, `sim_door`,
   `all_parts` (single build plate), or `assembly` (exploded preview)
3. Render (F6) → Export as STL → slice

Suggested settings: PLA, 0.2 mm layers, 3 walls, 15% infill, no supports.
Orientation: shell front-face down, lid flat (emboss up), button cap-down.

Key parameters (all at the top of the file): `body_w`, `body_l`, `body_t`,
`corner_r`, `wall`, `button_hole_d`, `strap_gap`.

## Assembly

1. Glue or screw the lid onto the shell using the four 2.2 mm posts (M2 self-tappers)
2. Press the cancel button plunger into the front hole — the flange retains it behind the face
3. Slide the SIM door into the lid rails; the USB-C slot and buzzer holes are pre-cut
4. Thread a velcro strap through the two side rail channels to mount on the handlebar or frame

## Electronics BOM (fits the 36 × 26 mm PCB bay)

| Part | Role |
|---|---|
| Arduino Nano / ESP32 | microcontroller |
| SIM800L module | GSM — sends the SMS alert |
| NEO-6M GPS | location fix |
| MPU-6050 accelerometer | fall detection |
| Tactile switch | cancel button (behind plunger) |
| Buzzer + LED | local alert / status |
| CR123A or LiPo cell | power |

## How it works

On a suspected fall (sudden deceleration + orientation change), the device starts a
15-second countdown. Pressing the cancel button aborts. Otherwise it sends an SMS
with a Google Maps link of the GPS coordinates to the emergency number.
