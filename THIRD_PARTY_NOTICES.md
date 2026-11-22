# Third-party notices

## CBA_A3

ArmaFPV depends on CBA_A3 at runtime. A copy of
`script_macros_common.hpp` is provided under `include/x/cba/` solely to support
reproducible HEMTT preprocessing. CBA_A3 is licensed under GPLv2 and is not
redistributed in release archives.

Source: https://github.com/CBATeam/CBA_A3

## Arma 3

Arma 3 classes and assets referenced by configuration are owned by Bohemia
Interactive and are not redistributed as source material by this project.

## Drongo's Drone Tweaks

`SDB_InteropTweaks` is an optional interoperability addon. Drongo's Drone
Tweaks is not bundled and retains its own license and distribution terms.

## Betaflight OSD font

The drone OSD uses the Betaflight analog OSD font (`resources/osd/2/betaflight.mcm`
from betaflight-configurator), licensed under GPL-3.0. The source file is kept
in `tools/osd_font/betaflight.mcm`; `tools/build_osd_font.py` converts it into
the `ArmaFPV_OSD` font files in `addons/ArmaFPV/font/osd`, which remain under
GPL-3.0.

Source: https://github.com/betaflight/betaflight-configurator

## Drone sounds

The drone engine, start and stop sounds in `addons/ArmaFPV/sounds` are built by
`tools/build_sounds.py` from these recordings by qubodup on Freesound, released
under CC0 1.0. The recordings come from public-domain U.S. Department of Defense
footage. The source files are kept in `tools/sound_src`.

- Quadcopter Drone Stalking Hovering 1: https://freesound.org/people/qubodup/sounds/854353/
- Quadcopter Drone Stalking Hovering 2: https://freesound.org/people/qubodup/sounds/854354/
- Drone Beep and Fly Away: https://freesound.org/people/qubodup/sounds/854646/
