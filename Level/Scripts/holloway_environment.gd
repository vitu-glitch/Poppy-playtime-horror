extends Node3D

# HOLLOWAY Research Center - C-04 Behavioral Testing Chamber.
# Decorative geometry is visual only. The original level floor and puzzle
# colliders remain responsible for gameplay physics.

const SECURITY_CAMERA_SCENE: PackedScene = preload("res://Decoration/Mesh/ch4Camera.glb")

var floor_material: Material
var wall_material: Material
var trim_material: StandardMaterial3D
var dark_material: StandardMaterial3D
var teal_material: StandardMaterial3D
var cream_material: StandardMaterial3D
var glass_material: StandardMaterial3D
var cyan_light_material: StandardMaterial3D
var amber_material: StandardMaterial3D
var green_screen_material: StandardMaterial3D
var amber_screen_material: StandardMaterial3D


func _ready() -> void:
    _create_materials()
    _apply_existing_surface_materials()
    _tune_existing_lighting()
    _build_room_shell()
    _build_wall_panels()
    _build_observation_window()
    _build_control_station()
    _build_ceiling_lighting()
    _build_room_signage()
    _place_security_cameras()


func _create_materials() -> void:
    floor_material = load("res://Decoration/Materials/IndustrialConcrete.tres") as Material
    wall_material = load("res://Decoration/Materials/IndustrialConcreteSmooth.tres") as Material

    if floor_material == null:
        floor_material = _make_material(Color(0.25, 0.29, 0.30), 0.05, 0.92)
    if wall_material == null:
        wall_material = _make_material(Color(0.52, 0.53, 0.49), 0.0, 0.88)

    trim_material = _make_material(Color(0.10, 0.14, 0.16), 0.72, 0.46)
    dark_material = _make_material(Color(0.025, 0.040, 0.048), 0.42, 0.62)
    teal_material = _make_material(Color(0.075, 0.19, 0.20), 0.24, 0.68)
    cream_material = _make_material(Color(0.67, 0.64, 0.54), 0.04, 0.82)
    glass_material = _make_material(Color(0.12, 0.30, 0.32, 0.32), 0.18, 0.16, Color(0.04, 0.12, 0.13), 0.12, true)
    cyan_light_material = _make_material(Color(0.68, 0.86, 0.88), 0.0, 0.34, Color(0.58, 0.86, 0.95), 1.8)
    amber_material = _make_material(Color(0.85, 0.48, 0.12), 0.18, 0.42, Color(0.95, 0.30, 0.04), 0.55)
    green_screen_material = _make_material(Color(0.045, 0.20, 0.15), 0.0, 0.28, Color(0.08, 0.72, 0.40), 1.15)
    amber_screen_material = _make_material(Color(0.24, 0.13, 0.035), 0.0, 0.28, Color(0.98, 0.42, 0.08), 0.95)


func _make_material(color: Color, metallic_value: float = 0.0, roughness_value: float = 0.75, emission_color: Color = Color.BLACK, emission_power: float = 0.0, transparent: bool = false) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = metallic_value
    material.roughness = roughness_value
    if emission_power > 0.0:
        material.emission_enabled = true
        material.emission = emission_color
        material.emission_energy_multiplier = emission_power
    if transparent:
        material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    return material


func _apply_existing_surface_materials() -> void:
    # Reuse the original CSG floor: no duplicate floor mesh or overlapping
    # floor collider is created.
    var main_floor := get_parent().get_node_or_null("CSG/Floor") as CSGBox3D
    if main_floor != null:
        main_floor.material = floor_material

    var rear_wall := get_parent().get_node_or_null("CSG/Floor2") as CSGBox3D
    if rear_wall != null:
        rear_wall.material = wall_material


func _tune_existing_lighting() -> void:
    var key_light := get_parent().get_node_or_null("DirectionalLight3D") as DirectionalLight3D
    if key_light != null:
        key_light.light_energy = 0.68
        key_light.light_color = Color(0.72, 0.82, 0.86)


func _add_box(node_name: String, size: Vector3, position: Vector3, material: Material, collision: bool = false, cast_shadow: bool = true) -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = size

    var instance := MeshInstance3D.new()
    instance.name = node_name
    instance.mesh = mesh
    instance.material_override = material
    instance.position = position
    instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(instance)

    # Only the room's perimeter walls receive collision. Decorative panels,
    # desks, lights and floor markings never affect the player's physics.
    if collision:
        var body := StaticBody3D.new()
        body.name = node_name + "_Collision"
        body.position = position
        add_child(body)

        var collision_shape := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        collision_shape.shape = shape
        body.add_child(collision_shape)

    return instance


func _add_light(position: Vector3, color: Color, energy: float, light_range: float) -> void:
    var light := OmniLight3D.new()
    light.position = position
    light.light_color = color
    light.light_energy = energy
    light.omni_range = light_range
    light.shadow_enabled = false
    add_child(light)


func _add_label(text_value: String, position: Vector3, rotation_y: float = 0.0, font_size_value: int = 30, color_value: Color = Color(0.80, 0.89, 0.86)) -> void:
    var label := Label3D.new()
    label.text = text_value
    label.position = position
    label.rotation_degrees.y = rotation_y
    label.font_size = font_size_value
    label.pixel_size = 0.0045
    label.modulate = color_value
    label.outline_size = 7
    label.outline_modulate = Color(0.015, 0.025, 0.03, 1.0)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    add_child(label)


func _build_room_shell() -> void:
    # Main room boundaries. These replace the temporary extra corridors and
    # side rooms; the gameplay space stays compact and legible.
    _add_box("Left_Perimeter_Wall", Vector3(0.48, 8.5, 19.2), Vector3(-18.82, 4.25, -1.65), wall_material, true)
    _add_box("Right_Perimeter_Wall", Vector3(0.48, 8.5, 19.2), Vector3(18.82, 4.25, -1.65), wall_material, true)

    # Staff entrance behind the player, deliberately wide and unobstructed.
    _add_box("Entry_Wall_Left", Vector3(14.5, 8.5, 0.48), Vector3(-11.75, 4.25, 8.0), wall_material, true)
    _add_box("Entry_Wall_Right", Vector3(14.5, 8.5, 0.48), Vector3(11.75, 4.25, 8.0), wall_material, true)
    _add_box("Entry_Wall_Lintel", Vector3(9.0, 1.05, 0.50), Vector3(0.0, 7.72, 8.0), teal_material)

    # A single dark ceiling gives the room a finished, enclosed silhouette.
    _add_box("Ceiling_Main", Vector3(38.0, 0.28, 19.2), Vector3(0.0, 8.58, -1.65), dark_material, false, false)
    _add_box("Ceiling_Perimeter_Trim", Vector3(37.6, 0.14, 0.18), Vector3(0.0, 8.36, 7.72), trim_material)
    _add_box("Ceiling_Perimeter_Trim_Back", Vector3(37.6, 0.14, 0.18), Vector3(0.0, 8.36, -11.02), trim_material)

    # Continuous lower wall band and top rail establish a consistent design.
    _add_box("Left_Lower_Wall_Band", Vector3(0.07, 2.15, 18.8), Vector3(-18.55, 1.18, -1.65), teal_material)
    _add_box("Right_Lower_Wall_Band", Vector3(0.07, 2.15, 18.8), Vector3(18.55, 1.18, -1.65), teal_material)
    _add_box("Left_Wall_Top_Rail", Vector3(0.12, 0.16, 18.9), Vector3(-18.53, 7.92, -1.65), trim_material)
    _add_box("Right_Wall_Top_Rail", Vector3(0.12, 0.16, 18.9), Vector3(18.53, 7.92, -1.65), trim_material)


func _build_wall_panels() -> void:
    # Repeated panels are aligned to a strict architectural rhythm.
    for index in range(6):
        var z_value: float = -8.9 + float(index) * 2.9

        _add_box("Left_Wall_Panel_%02d" % index, Vector3(0.06, 2.55, 2.55), Vector3(-18.55, 4.75, z_value), wall_material)
        _add_box("Right_Wall_Panel_%02d" % index, Vector3(0.06, 2.55, 2.55), Vector3(18.55, 4.75, z_value), wall_material)

        _add_box("Left_Wall_Panel_Seam_%02d" % index, Vector3(0.035, 2.50, 0.045), Vector3(-18.50, 4.75, z_value + 1.28), trim_material)
        _add_box("Right_Wall_Panel_Seam_%02d" % index, Vector3(0.035, 2.50, 0.045), Vector3(18.50, 4.75, z_value + 1.28), trim_material)

    # A restrained safety border follows the usable floor perimeter.
    _add_box("Floor_Safety_Line_Left", Vector3(0.075, 0.012, 16.7), Vector3(-16.6, 0.008, -1.65), amber_material)
    _add_box("Floor_Safety_Line_Right", Vector3(0.075, 0.012, 16.7), Vector3(16.6, 0.008, -1.65), amber_material)
    _add_box("Floor_Safety_Line_Front", Vector3(33.2, 0.012, 0.075), Vector3(0.0, 0.008, 6.55), amber_material)


func _build_observation_window() -> void:
    # One large, framed window instead of multiple small decorative objects.
    _add_box("Observation_Glass", Vector3(0.07, 2.75, 7.1), Vector3(-18.55, 5.1, -1.6), glass_material)
    _add_box("Observation_Frame_Top", Vector3(0.15, 0.16, 7.35), Vector3(-18.49, 6.58, -1.6), trim_material)
    _add_box("Observation_Frame_Bottom", Vector3(0.15, 0.16, 7.35), Vector3(-18.49, 3.62, -1.6), trim_material)
    _add_box("Observation_Frame_Left", Vector3(0.15, 3.0, 0.16), Vector3(-18.49, 5.1, -5.25), trim_material)
    _add_box("Observation_Frame_Right", Vector3(0.15, 3.0, 0.16), Vector3(-18.49, 5.1, 2.05), trim_material)

    for z_value in [-3.95, -1.6, 0.75]:
        _add_box("Observation_Glass_Mullion", Vector3(0.15, 2.9, 0.10), Vector3(-18.49, 5.1, z_value), trim_material)

    _add_box("Observation_Name_Plate", Vector3(0.07, 0.52, 4.0), Vector3(-18.55, 7.12, -1.6), teal_material)
    _add_label("OBSERVATION // C-04", Vector3(-18.38, 7.12, -1.6), -90.0, 19, Color(0.85, 0.79, 0.59))


func _build_control_station() -> void:
    # A single integrated monitoring console, aligned with the right wall.
    var desk_center := Vector3(13.35, 0.0, 0.45)
    _add_box("Console_Countertop", Vector3(6.3, 0.14, 1.45), desk_center + Vector3(0.0, 1.02, 0.0), cream_material)
    _add_box("Console_Front_Fascia", Vector3(6.12, 0.78, 0.10), desk_center + Vector3(0.0, 0.60, 0.62), teal_material)
    _add_box("Console_Left_Support", Vector3(0.16, 0.94, 1.20), desk_center + Vector3(-2.90, 0.48, 0.0), trim_material)
    _add_box("Console_Right_Support", Vector3(0.16, 0.94, 1.20), desk_center + Vector3(2.90, 0.48, 0.0), trim_material)

    var screen_positions: Array[float] = [11.25, 13.35, 15.45]
    var screen_labels: Array[String] = ["CAM 01", "SUBJECT", "CAM 04"]
    for index in range(3):
        var screen_x: float = screen_positions[index]
        var screen_material: Material = amber_screen_material if index == 1 else green_screen_material
        _add_box("CRT_Housing_%02d" % index, Vector3(1.55, 1.02, 0.18), Vector3(screen_x, 1.78, -0.22), dark_material)
        _add_box("CRT_Display_%02d" % index, Vector3(1.38, 0.82, 0.025), Vector3(screen_x, 1.79, -0.115), screen_material)
        _add_box("CRT_Status_Light_%02d" % index, Vector3(0.16, 0.035, 0.025), Vector3(screen_x - 0.52, 1.27, -0.33), amber_material)
        _add_label(screen_labels[index], Vector3(screen_x, 1.80, -0.085), 0.0, 12, Color(0.69, 1.0, 0.82))

    _add_box("Console_Keyboard_Left", Vector3(1.35, 0.045, 0.38), Vector3(11.45, 1.12, 0.90), trim_material)
    _add_box("Console_Keyboard_Center", Vector3(1.35, 0.045, 0.38), Vector3(13.35, 1.12, 0.90), trim_material)
    _add_box("Console_Keyboard_Right", Vector3(1.35, 0.045, 0.38), Vector3(15.25, 1.12, 0.90), trim_material)

    # A closed cabinet and one wall-mounted system panel finish the station.
    _add_box("Console_Equipment_Cabinet", Vector3(1.0, 2.1, 0.82), Vector3(17.55, 1.05, 3.45), trim_material)
    _add_box("Console_Cabinet_Label", Vector3(0.70, 0.20, 0.025), Vector3(17.55, 1.78, 3.02), cream_material)
    _add_box("Wall_System_Panel", Vector3(0.12, 1.75, 2.9), Vector3(18.55, 4.5, 0.3), dark_material)
    _add_box("Wall_System_Panel_Display", Vector3(0.035, 1.0, 2.2), Vector3(18.48, 4.72, 0.3), green_screen_material)
    _add_label("SYSTEM STATUS // C-04", Vector3(18.40, 5.65, 0.3), 90.0, 16, Color(0.68, 0.96, 0.80))


func _build_ceiling_lighting() -> void:
    # Eight evenly spaced fixtures provide a clean, deliberate light grid.
    var x_positions: Array[float] = [-12.0, -4.0, 4.0, 12.0]
    var z_positions: Array[float] = [-5.3, 3.0]

    for x_value in x_positions:
        for z_value in z_positions:
            _add_box("Recessed_Fluorescent_Panel", Vector3(2.75, 0.075, 0.42), Vector3(x_value, 8.38, z_value), cyan_light_material, false, false)
            _add_light(Vector3(x_value, 7.76, z_value), Color(0.67, 0.83, 0.90), 1.0, 9.5)

    # Small amber indicators sit only at the controlled entrance and gate.
    _add_box("Gate_Status_Lamp", Vector3(0.34, 0.22, 0.12), Vector3(5.4, 6.75, -5.02), amber_material)
    _add_light(Vector3(5.4, 6.42, -4.8), Color(1.0, 0.24, 0.06), 0.48, 3.2)


func _build_room_signage() -> void:
    # Main gate sign sits above the existing gate and does not cover its opening.
    _add_box("Gate_Header_Panel", Vector3(9.2, 1.35, 0.10), Vector3(5.4, 6.95, -5.61), teal_material)
    _add_box("Gate_Header_Accent", Vector3(8.75, 0.045, 0.035), Vector3(5.4, 6.30, -5.54), amber_material)
    _add_label("HOLLOWAY RESEARCH CENTER", Vector3(5.4, 7.13, -5.53), 0.0, 25, Color(0.91, 0.84, 0.66))
    _add_label("BEHAVIORAL TEST CHAMBER  //  C-04", Vector3(5.4, 6.72, -5.53), 0.0, 15, Color(0.74, 0.90, 0.86))

    _add_label("AUTHORIZED PERSONNEL ONLY", Vector3(0.0, 7.0, 7.70), 0.0, 19, Color(0.92, 0.68, 0.34))
    _add_label("OBSERVATION WING  /  LEVEL 02", Vector3(0.0, 6.58, 7.70), 0.0, 13, Color(0.78, 0.86, 0.82))


func _place_security_cameras() -> void:
    _add_security_camera(Vector3(-18.05, 6.35, -9.55), 35.0)
    _add_security_camera(Vector3(18.05, 6.35, -9.55), -145.0)
    _add_security_camera(Vector3(18.05, 6.35, 6.25), -35.0)


func _add_security_camera(position_value: Vector3, rotation_y: float) -> void:
    var camera_instance := SECURITY_CAMERA_SCENE.instantiate()
    if camera_instance is Node3D:
        var camera_node := camera_instance as Node3D
        camera_node.name = "Holloway_Security_Camera"
        camera_node.position = position_value
        camera_node.rotation_degrees.y = rotation_y
        camera_node.scale = Vector3.ONE * 0.34
        add_child(camera_node)
