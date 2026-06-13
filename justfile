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

# Re-render ALL committed PNGs: 5 views + 2 inspection cross-sections.
persp := "--imgsize=1500,1100 --colorscheme=Tomorrow --projection=perspective --viewall --autocenter --render"
ortho := "--imgsize=1500,1000 --colorscheme=Tomorrow --projection=ortho --viewall --autocenter --render"
preview:
    OPENSCADPATH={{oscadpath}} {{render}} -D '$fn={{fn}}' {{persp}} --camera=150,-300,300,0,6,10    -o images/plate-hero.png    {{src}}
    OPENSCADPATH={{oscadpath}} {{render}} -D '$fn={{fn}}' {{persp}} --camera=0,-25,430,0,-6,14      -o images/plate-front.png   {{src}}
    OPENSCADPATH={{oscadpath}} {{render}} -D '$fn={{fn}}' {{persp}} --camera=430,-30,90,0,-6,20     -o images/plate-side.png    {{src}}
    OPENSCADPATH={{oscadpath}} {{render}} -D '$fn={{fn}}' {{persp}} --camera=20,150,210,0,0,8       -o images/plate-topdown.png {{src}}
    OPENSCADPATH={{oscadpath}} {{render}} -D '$fn={{fn}}' --imgsize=1500,1100 --colorscheme=Tomorrow --projection=perspective --render --camera=-58,-150,150,-58,-2,10 -o images/zoom-cup.png {{src}}
    OPENSCADPATH={{oscadpath}} {{render}} -D '$fn={{fn}}' -D 'section=1' {{ortho}} --camera=400,0,40,-58,0,30   -o images/section-cup.png    {{src}}
    OPENSCADPATH={{oscadpath}} {{render}} -D '$fn={{fn}}' -D 'section=2' {{ortho}} --camera=0,-400,40,0,-32,20  -o images/section-cavity.png {{src}}

# Print the derived dimensions (plate size, cup bore, lift) without exporting.
dims:
    OPENSCADPATH={{oscadpath}} {{openscad}} -o /tmp/fi-dims.csg {{src}} 2>&1 | grep ECHO; rm -f /tmp/fi-dims.csg

blender := env_var_or_default("BLENDER", "/home/will/opt/blender-4.4.3-linux-x64/blender")

# Blender Cycles render: blender-hero.png + blender-front.png
render-blender:
    {{blender}} --background --python src/blender-render.py

# Remove generated meshes (PNGs are committed).
clean:
    rm -f export/*.stl
