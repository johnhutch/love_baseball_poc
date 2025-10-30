
# SimpleBaseball (LÖVE 2D)

A tiny, 16‑bit‑era‑inspired baseball batting demo built with LÖVE 2D.

## Controls
- **1 / 2 / 3** — Select pitch type (Fastball / Curve / Changeup)
- **P** — Pitch the selected pitch
- **SPACE** — Swing the bat
- **Up / Down** — Adjust bat angle (loft vs grounder)
- **R** — Reset ball to pitcher
- **ESC** — Quit

## How to run
1. Install [LÖVE](https://love2d.org/).
2. Download and unzip this project.
3. Run from terminal:
   ```bash
   love SimpleBaseball
   ```

## Notes
- The ball is pitched from the mound to the plate.
- During a swing window, if the ball is in the hittable zone, contact is made and
  the exit velocity and direction are computed based on bat angle and incoming pitch speed.
- Curveball has lateral/downward break; Changeup is slower with a light arm‑side fade.
# love_baseball_poc
