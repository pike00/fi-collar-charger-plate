# Fi collar charger plate — build / render recipes
# OpenSCAD 2021.01 on PATH. Override the binary with OPENSCAD=/path/to/AppImage.

openscad := env_var_or_default("OPENSCAD", "openscad")
# BOSL2 lives in the shared user library dir; export it so `include` resolves.
oscadpath := env_var_or_default("OPENSCADPATH", "/home/will/.local/share/OpenSCAD/libraries")
# Headless host (no X display): xvfb-run gives OpenSCAD a GL context for PNGs.
render   := env_var_or_default("RENDER", "xvfb-run -a " + openscad)
src      := "src/fi-collar-charger-plate.scad"
fn       := "96"

default:
    @just --list

# Export the print-ready plate at high $fn.
build:
    OPENSCADPATH={{oscadpath}} {{openscad}} -D '$fn={{fn}}' \
        -o export/fi-collar-charger-plate.stl {{src}}

build-all: build

# Re-render the committed preview PNGs (STL export needs no GL; PNGs do).
view := "--imgsize=1600,1200 --colorscheme=Tomorrow --projection=perspective --viewall --render"
preview:
    OPENSCADPATH={{oscadpath}} {{render}} {{view}} \
        --camera=0,0,0,55,0,20,1 -o images/plate-hero.png {{src}}
    OPENSCADPATH={{oscadpath}} {{render}} {{view}} \
        --camera=0,0,0,0,0,0,1 -o images/plate-front.png {{src}}

# Print the derived dimensions (plate size, cup bore) without exporting.
dims:
    OPENSCADPATH={{oscadpath}} {{openscad}} -o /dev/null {{src}} 2>&1 | grep ECHO

# Remove generated meshes (PNGs are committed).
clean:
    rm -f export/*.stl
