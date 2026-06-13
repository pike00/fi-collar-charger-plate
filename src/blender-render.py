"""
Blender headless render — fi-collar-charger-plate.
Run: just render-blender
Single color: warm off-white PLA. Plate is 162x123mm, cups stick out ~37mm.
"""
import bpy
import os
import math
from mathutils import Vector

BASE_DIR   = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EXPORT_DIR = os.path.join(BASE_DIR, "export")
HDRI_PATH  = os.path.expanduser("~/opt/blender-assets/studio_small_09_2k.exr")

# ── clean scene ───────────────────────────────────────────────────────────────
for obj in list(bpy.data.objects):
    bpy.data.objects.remove(obj, do_unlink=True)

# ── render settings ───────────────────────────────────────────────────────────
scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.samples = 256
scene.cycles.use_denoising = True
scene.cycles.caustics_refractive = True
scene.cycles.caustics_reflective = True
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.render.image_settings.file_format = "PNG"
scene.render.film_transparent = False

# ── materials: photorealistic PLA ─────────────────────────────────────────────
def plastic_pla(name, r, g, b, roughness=0.42, sss=0.008):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    bsdf = nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (r, g, b, 1.0)
    bsdf.inputs["Roughness"].default_value  = roughness
    bsdf.inputs["Subsurface Weight"].default_value = sss
    bsdf.inputs["Subsurface Radius"].default_value = (r * 0.6, g * 0.6, b * 0.6)
    bsdf.inputs["Subsurface Scale"].default_value  = 2.5
    rgh_noise = nodes.new("ShaderNodeTexNoise")
    rgh_noise.inputs["Scale"].default_value     = 12.0
    rgh_noise.inputs["Detail"].default_value    = 6.0
    rgh_noise.inputs["Roughness"].default_value = 0.7
    rgh_map = nodes.new("ShaderNodeMapRange")
    rgh_map.inputs["To Min"].default_value = roughness - 0.08
    rgh_map.inputs["To Max"].default_value = roughness + 0.08
    links.new(rgh_noise.outputs["Fac"], rgh_map.inputs["Value"])
    links.new(rgh_map.outputs["Result"], bsdf.inputs["Roughness"])
    bump_noise = nodes.new("ShaderNodeTexNoise")
    bump_noise.inputs["Scale"].default_value      = 90.0
    bump_noise.inputs["Detail"].default_value     = 2.0
    bump_noise.inputs["Roughness"].default_value  = 0.6
    bump_noise.inputs["Distortion"].default_value = 0.2
    bump = nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.12
    bump.inputs["Distance"].default_value = 0.4
    links.new(bump_noise.outputs["Fac"], bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])
    return mat

m_body   = plastic_pla("body", 0.90, 0.88, 0.86)   # warm off-white PLA
m_ground = bpy.data.materials.new("Ground")
m_ground.use_nodes = True
m_ground.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.22, 0.22, 0.23, 1.0)
m_ground.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value  = 0.95

# ── import STL ───────────────────────────────────────────────────────────────
PARTS = [("fi-collar-charger-plate.stl", m_body)]

for fname, mat in PARTS:
    before = set(bpy.data.objects.keys())
    bpy.ops.wm.stl_import(filepath=os.path.join(EXPORT_DIR, fname))
    obj = bpy.data.objects[(set(bpy.data.objects.keys()) - before).pop()]
    obj.data.materials.clear()
    obj.data.materials.append(mat)
    for poly in obj.data.polygons:
        poly.use_smooth = True
    obj.cycles.is_caustics_caster = True

# ── studio ground plane ───────────────────────────────────────────────────────
bpy.ops.mesh.primitive_plane_add(size=1500, location=(0, 0, -0.5))
ground = bpy.context.object
ground.name = "Ground"
ground.data.materials.append(m_ground)
ground.cycles.is_caustics_receiver = True

# ── world: HDRI ───────────────────────────────────────────────────────────────
scene.world.use_nodes = True
nt = scene.world.node_tree
nt.nodes.clear()
coord   = nt.nodes.new("ShaderNodeTexCoord")
mapping = nt.nodes.new("ShaderNodeMapping")
mapping.inputs["Rotation"].default_value = (0, 0, math.radians(45))
env = nt.nodes.new("ShaderNodeTexEnvironment")
env.image = bpy.data.images.load(HDRI_PATH)
bg  = nt.nodes.new("ShaderNodeBackground")
bg.inputs["Strength"].default_value = 1.2
out = nt.nodes.new("ShaderNodeOutputWorld")
nt.links.new(coord.outputs["Generated"], mapping.inputs["Vector"])
nt.links.new(mapping.outputs["Vector"],  env.inputs["Vector"])
nt.links.new(env.outputs["Color"],       bg.inputs["Color"])
nt.links.new(bg.outputs["Background"],   out.inputs["Surface"])

# ── 3-point area lights ───────────────────────────────────────────────────────
def area_light(loc, energy, size, target=(0, 0, 20)):
    bpy.ops.object.light_add(type="AREA", location=loc)
    lt = bpy.context.object
    lt.data.energy = energy
    lt.data.size   = size
    lt.rotation_euler = (Vector(target) - lt.location).to_track_quat("-Z", "Y").to_euler()
    return lt

# Plate is 162x123mm, cups ~37mm tall — scale lights accordingly
area_light(( 120, -300, 280), energy=60000, size=250)   # key
area_light((-280,   80, 160), energy=24000, size=320)   # fill
area_light((   0,  280, 120), energy=22000, size=160)   # rim

# ── compositor: chromatic aberration + vignette ───────────────────────────────
scene.use_nodes = True
ct = scene.node_tree
ct.nodes.clear()
rl   = ct.nodes.new("CompositorNodeRLayers")
comp = ct.nodes.new("CompositorNodeComposite")
lens = ct.nodes.new("CompositorNodeLensdist")
lens.inputs["Distortion"].default_value = 0.0
lens.inputs["Dispersion"].default_value = 0.012
ell  = ct.nodes.new("CompositorNodeEllipseMask")
ell.mask_width  = 0.82
ell.mask_height = 0.82
blr  = ct.nodes.new("CompositorNodeBlur")
blr.filter_type = "GAUSS"
blr.size_x = blr.size_y = 140
inv  = ct.nodes.new("CompositorNodeInvert")
scl  = ct.nodes.new("CompositorNodeMath")
scl.operation = "MULTIPLY"
scl.inputs[1].default_value = 0.40
mix  = ct.nodes.new("CompositorNodeMixRGB")
mix.blend_type = "MIX"
mix.inputs[2].default_value = (0.0, 0.0, 0.0, 1.0)
ct.links.new(rl.outputs["Image"],   lens.inputs["Image"])
ct.links.new(lens.outputs["Image"], mix.inputs[1])
ct.links.new(ell.outputs["Mask"],   blr.inputs["Image"])
ct.links.new(blr.outputs["Image"],  inv.inputs["Color"])
ct.links.new(inv.outputs["Color"],  scl.inputs[0])
ct.links.new(scl.outputs["Value"],  mix.inputs["Fac"])
ct.links.new(mix.outputs["Image"],  comp.inputs["Image"])

# ── camera ────────────────────────────────────────────────────────────────────
def set_camera(location, target=(0, 0, 20), lens=70, dof_fstop=None):
    if not scene.camera:
        cam_obj = bpy.data.objects.new("Camera", bpy.data.cameras.new("Cam"))
        scene.collection.objects.link(cam_obj)
        scene.camera = cam_obj
    cam_obj = scene.camera
    cam_obj.data.lens = lens
    cam_obj.location  = Vector(location)
    cam_obj.rotation_euler = (Vector(target) - cam_obj.location).to_track_quat("-Z", "Y").to_euler()
    if dof_fstop:
        cam_obj.data.dof.use_dof = True
        cam_obj.data.dof.focus_distance = (cam_obj.location - Vector(target)).length
        cam_obj.data.dof.aperture_fstop = dof_fstop

# Hero: 3/4 view — plate is 162×123mm, cups ~24mm tall.
# Pull back ~580mm so the full plate fits the 70mm frame with breathing room.
# Keep elevation shallow (18°) to show the plate face, not the overhead.
set_camera((110, -560, 185), target=(0, 0, 12), lens=70, dof_fstop=8.0)
scene.render.filepath = os.path.join(BASE_DIR, "images", "blender-hero.png")
bpy.ops.render.render(write_still=True)
print("Rendered:", scene.render.filepath)

# Front view: straight on, 85mm to avoid cutting off plate edges.
set_camera((0, -500, 55), target=(0, 0, 12), lens=85)
scene.render.filepath = os.path.join(BASE_DIR, "images", "blender-front.png")
bpy.ops.render.render(write_still=True)
print("Rendered:", scene.render.filepath)
