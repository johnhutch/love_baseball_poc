# SimpleBaseball

A dumb little 8‑bit‑era‑inspired baseball batting POC thing built with LÖVE 2D cause I'm tryna learn this shit..

## Controls
- **1 / 2 / 3** — Select pitch type (Fastball / Curve / Changeup)
- **P** — Pitch the selected pitch
- **SPACE** — Swing the fuggin bat
- **Left/Right** - move the guy back and forth 
- **R** — Manually reset to pitch again cause i haven't done that stuff yet.
- **ESC** — Quit

## How to run
1. Install [LÖVE](https://love2d.org/).
2. Download and unzip this project.
3. cd into the dir
4. Run from terminal:
   ```bash
   love .
   ```

## Notes
- The ball is pitched from the mound to the plate.
- During a swing window, if there's a bat/ball collision,
  the exit velo and angle are based on the bat angle and pitch speed.
- Curveball has a break; Changeup is slower slight fade.
