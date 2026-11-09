extends Node3D

# HOLLOWAY Research Center - environment dressing for the first playable area.
# The existing puzzle objects and player are deliberately left untouched.

const SECURITY_CAMERA_SCENE: PackedScene = preload("res://Decoration/Mesh/ch4Camera.glb")
const TRASHCAN_SCENE: PackedScene = preload("res://Decoration/Mesh/ch4trashcans.glb")

var floor_material: Material
var wall_material: Material
var rough_material: Material
var wood_material: Material

var metal: StandardMaterial3D
var dark_metal: StandardMaterial3D
var painted_wall: StandardMaterial3D
var panel_blue: StandardMaterial3D
var panel_cream: StandardMaterial3D
var glass: StandardMaterial3D
var yellow: StandardMaterial3D
var warning_red: StandardMaterial3D
var fluorescent: StandardMaterial3D
var screen_green: StandardMaterial3D
var screen_amber: StandardMaterial3D
var black: StandardMaterial3D

func _ready() -> void:
	_create_materials()
	_build_main_room()
	_build_main_room_details()
	_build_control_station()
	_build_security_cameras()
	_build_service_corridor()
	_build_observation_lab()
	_build_entry_airlock()


func _create_materials() -> void:
	floor_material = load("res://Decoration/Materials/IndustrialConcrete.tres") as Material
	wall_material = load("res://Decoration/Materials/IndustrialConcreteSmooth.tres") as Material
	rough_material = load("res://Decoration/Materials/ConcreteRough.tres") as Material
	wood_material = load("res://Decoration/Materials/Wood.tres") as Material

	if floor_material == null:
		floor_material = _make_material(Color(0.28, 0.31, 0.32), 0.15, 0.9)
	if wall_material == null:
		wall_material = _make_material(Color(0.48, 0.49, 0.45), 0.05, 0.88)
	if rough_material == null:
		rough_material = _make_material(Color(0.22, 0.25, 0.26), 0.0, 1.0)
	if wood_material == null:
		wood_material = _make_material(Color(0.22, 0.14, 0.08), 0.05, 0.85)

	metal = _make_material(Color(0.19, 0.24, 0.27), 0.78, 0.38)
	dark_metal = _make_material(Color(0.055, 0.075, 0.085), 0.72, 0.5)
	painted_wall = _make_material(Color(0.28, 0.34, 0.34), 0.12, 0.78)
	panel_blue = _make_material(Color(0.075, 0.19, 0.22), 0.35, 0.52)
	panel_cream = _make_material(Color(0.57, 0.54, 0.44), 0.08, 0.75)
	glass = _make_material(Color(0.10, 0.25, 0.28, 0.30), 0.28, 0.15, Color.BLACK, 0.0, true)
	yellow = _make_material(Color(0.95, 0.62, 0.12), 0.25, 0.5)
	warning_red = _make_material(Color(0.8, 0.045, 0.025), 0.25, 0.35, Color(1.0, 0.025, 0.01), 1.8)
	fluorescent = _make_material(Color(0.73, 0.91, 0.91), 0.0, 0.35, Color(0.65, 0.92, 1.0), 2.2)
	screen_green = _make_material(Color(0.08, 0.28, 0.22), 0.1, 0.25, Color(0.08, 0.8, 0.48), 1.4)
	screen_amber = _make_material(Color(0.34, 0.20, 0.055), 0.1, 0.25, Color(1.0, 0.48, 0.09), 1.0)
	black = _make_material(Color(0.018, 0.025, 0.028), 0.35, 0.58)


func _make_material(color: Color, metallic_value: float = 0.0, roughness_value: float = 0.75, emission_color: Color = Color(0.0, 0.0, 0.0), emission_power: float = 0.0, transparent: bool = false) -> StandardMaterial3D:
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


func _add_box(parent: Node3D, node_name: String, size: Vector3, position: Vector3, material: Material, solid: bool = false, rotation_degrees_value: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var box_mesh := BoxMesh.new()
	box_mesh.size = size

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = material
	mesh_instance.position = position
	mesh_instance.rotation_degrees = rotation_degrees_value
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mesh_instance)

	if solid:
		var body := StaticBody3D.new()
		body.name = node_name + "_Collision"
		body.position = position
		body.rotation_degrees = rotation_degrees_value
		parent.add_child(body)

		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)

	return mesh_instance


func _add_cylinder(parent: Node3D, node_name: String, length: float, radius: float, position: Vector3, material: Material, rotation_degrees_value: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = length
	cylinder.radial_segments = 12

	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = cylinder
	instance.material_override = material
	instance.position = position
	instance.rotation_degrees = rotation_degrees_value
	parent.add_child(instance)
	return instance


func _add_label(parent: Node3D, label_text: String, position: Vector3, rotation_y: float = 0.0, font_size_value: int = 32, label_color: Color = Color(0.68, 0.91, 0.88)) -> Label3D:
	var label := Label3D.new()
	label.text = label_text
	label.position = position
	label.rotation_degrees.y = rotation_y
	label.font_size = font_size_value
	label.pixel_size = 0.004
	label.modulate = label_color
	label.outline_size = 8
	label.outline_modulate = Color(0.015, 0.025, 0.03, 1.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	parent.add_child(label)
	return label


func _add_light(parent: Node3D, position: Vector3, color: Color = Color(0.70, 0.88, 1.0), energy: float = 1.25, light_range: float = 11.0) -> void:
	var light := OmniLight3D.new()
	light.position = position
	light.light_color = color
	light.light_energy = energy
	light.omni_range = light_range
	light.shadow_enabled = false
	parent.add_child(light)


func _add_camera(parent: Node3D, position: Vector3, rotation_y: float, scale_value: float = 0.36) -> void:
	var camera_instance := SECURITY_CAMERA_SCENE.instantiate()
	if camera_instance is Node3D:
		var camera_node := camera_instance as Node3D
		camera_node.name = "Holloway_Security_Camera"
		camera_node.position = position
		camera_node.rotation_degrees.y = rotation_y
		camera_node.scale = Vector3.ONE * scale_value
		parent.add_child(camera_node)


func _add_desk(parent: Node3D, center: Vector3, width: float, depth: float, top_material: Material = null) -> void:
	var top := wood_material if top_material == null else top_material
	_add_box(parent, "Desk_Top", Vector3(width, 0.13, depth), center + Vector3(0.0, 1.02, 0.0), top)
	_add_box(parent, "Desk_Front", Vector3(width - 0.15, 0.72, 0.12), center + Vector3(0.0, 0.60, depth * 0.34), dark_metal)
	_add_box(parent, "Desk_Left_Leg", Vector3(0.14, 0.98, 0.14), center + Vector3(-width * 0.44, 0.49, 0.0), metal)
	_add_box(parent, "Desk_Right_Leg", Vector3(0.14, 0.98, 0.14), center + Vector3(width * 0.44, 0.49, 0.0), metal)


func _add_monitor(parent: Node3D, position: Vector3, screen_material: Material, screen_label: String = "CAM 04") -> void:
	_add_box(parent, "Monitor_Housing", Vector3(1.25, 0.88, 0.14), position, dark_metal)
	_add_box(parent, "Monitor_Screen", Vector3(1.10, 0.70, 0.025), position + Vector3(0.0, 0.0, -0.083), screen_material)
	_add_box(parent, "Monitor_Stand", Vector3(0.16, 0.27, 0.20), position + Vector3(0.0, -0.54, 0.015), metal)
	_add_box(parent, "Monitor_Base", Vector3(0.55, 0.07, 0.34), position + Vector3(0.0, -0.68, 0.02), dark_metal)
	_add_label(parent, screen_label, position + Vector3(0.0, -0.34, -0.103), 0.0, 12, Color(0.55, 1.0, 0.79))


func _build_main_room() -> void:
	# The original floor and puzzle remain in place. This textured layer sits directly on top.
	_add_box(self, "Textured_Industrial_Floor", Vector3(37.75, 0.035, 18.85), Vector3(0.0, 0.018, -1.65), floor_material)

	# Side walls and the rear entry wall frame the original mechanics room.
	_add_box(self, "Left_Outer_Wall", Vector3(0.48, 8.8, 19.2), Vector3(-18.82, 4.4, -1.65), wall_material, true)
	_add_box(self, "Right_Outer_Wall", Vector3(0.48, 8.8, 19.2), Vector3(18.82, 4.4, -1.65), wall_material, true)

	# Leave an eight-metre opening behind the player for the staff airlock.
	_add_box(self, "Front_Wall_Left", Vector3(15.0, 8.8, 0.48), Vector3(-11.5, 4.4, 8.0), wall_material, true)
	_add_box(self, "Front_Wall_Right", Vector3(15.0, 8.8, 0.48), Vector3(11.5, 4.4, 8.0), wall_material, true)
	_add_box(self, "Front_Door_Lintel", Vector3(8.0, 2.0, 0.55), Vector3(0.0, 7.8, 8.0), painted_wall, true)

	_add_box(self, "Main_Ceiling", Vector3(38.0, 0.32, 19.2), Vector3(0.0, 8.72, -1.65), dark_metal)

	# The original large gate is kept clear. Cladding is split around its opening.
	_add_box(self, "Rear_Wall_Cladding_Left", Vector3(21.0, 8.2, 0.12), Vector3(-7.2, 4.1, -5.57), painted_wall)
	_add_box(self, "Rear_Wall_Cladding_Right", Vector3(11.0, 8.2, 0.12), Vector3(13.7, 4.1, -5.57), painted_wall)
	_add_box(self, "Rear_Upper_Cladding", Vector3(8.0, 3.6, 0.12), Vector3(5.4, 7.0, -5.57), painted_wall)
	_add_label(self, "HOLLOWAY RESEARCH CENTER  //  OBSERVATION WING C-04", Vector3(5.4, 6.15, -5.68), 180.0, 23, Color(0.92, 0.78, 0.48))

	# Industrial baseboards, upper trim and structural wall ribs.
	for side in [-1.0, 1.0]:
		var x := side * 18.53
		_add_box(self, "Wall_Base_Trim", Vector3(0.16, 0.24, 18.9), Vector3(x, 0.25, -1.65), dark_metal)
		_add_box(self, "Wall_Upper_Trim", Vector3(0.20, 0.18, 18.9), Vector3(x, 7.95, -1.65), metal)
		_add_box(self, "Wall_Safety_Stripe", Vector3(0.055, 0.12, 18.8), Vector3(side * 18.45, 2.7, -1.65), yellow)
		for z_value in [-9.0, -5.2, -1.4, 2.4, 6.2]:
			_add_box(self, "Wall_Structural_Rib", Vector3(0.22, 8.2, 0.16), Vector3(side * 18.52, 4.1, z_value), metal)

	# Textured floor insets and worn safety markings.
	for x_value in [-15.0, -10.0, -5.0, 0.0, 5.0, 10.0, 15.0]:
		_add_box(self, "Floor_Tile_Seam", Vector3(0.025, 0.012, 17.8), Vector3(x_value, 0.041, -1.65), dark_metal)
	_add_box(self, "Yellow_Floor_Line_Left", Vector3(0.10, 0.014, 17.5), Vector3(-16.9, 0.045, -1.65), yellow)
	_add_box(self, "Yellow_Floor_Line_Right", Vector3(0.10, 0.014, 17.5), Vector3(16.9, 0.045, -1.65), yellow)

	# Overhead structural beams.
	for z_value in [-8.0, -3.0, 2.0, 7.0]:
		_add_box(self, "Ceiling_Cross_Beam", Vector3(37.0, 0.24, 0.24), Vector3(0.0, 8.43, z_value), metal)

	_add_label(self, "TEST CHAMBER 04", Vector3(0.0, 7.15, 7.72), 0.0, 29, Color(0.86, 0.84, 0.69))
	_add_label(self, "AUTHORIZED PERSONNEL ONLY", Vector3(0.0, 6.55, 7.72), 0.0, 15, Color(0.95, 0.64, 0.22))


func _build_main_room_details() -> void:
	# Observation glass on the left, looking into the testing chamber.
	_add_box(self, "Observation_Window_Glass", Vector3(0.07, 2.8, 6.5), Vector3(-18.48, 4.9, -1.8), glass)
	_add_box(self, "Observation_Window_Top_Frame", Vector3(0.16, 0.16, 6.8), Vector3(-18.42, 6.35, -1.8), metal)
	_add_box(self, "Observation_Window_Bottom_Frame", Vector3(0.16, 0.16, 6.8), Vector3(-18.42, 3.45, -1.8), metal)
	for z_value in [-5.1, -1.8, 1.5]:
		_add_box(self, "Observation_Window_Mullion", Vector3(0.16, 2.9, 0.14), Vector3(-18.42, 4.9, z_value), metal)
	_add_label(self, "OBSERVATION BAY 01", Vector3(-18.36, 6.75, -1.8), -90.0, 18, Color(0.78, 0.9, 0.82))

	# Utility pipes and electrical cable trays running above the room.
	_add_cylinder(self, "Ceiling_Pipe_Red", 34.0, 0.12, Vector3(0.0, 7.95, -7.4), warning_red, Vector3(0.0, 0.0, 90.0))
	_add_cylinder(self, "Ceiling_Pipe_Blue", 34.0, 0.10, Vector3(0.0, 7.78, -6.6), panel_blue, Vector3(0.0, 0.0, 90.0))
	_add_cylinder(self, "Ceiling_Pipe_Steel", 34.0, 0.16, Vector3(0.0, 7.62, 6.2), metal, Vector3(0.0, 0.0, 90.0))
	_add_box(self, "Cable_Tray_Main", Vector3(35.0, 0.16, 0.55), Vector3(0.0, 8.12, 3.4), dark_metal)
	for x_value in [-14.0, -7.0, 0.0, 7.0, 14.0]:
		_add_box(self, "Cable_Tray_Hanger", Vector3(0.08, 0.42, 0.08), Vector3(x_value, 8.25, 3.4), metal)

	# Fluorescent fixtures give the room a cold institutional look.
	for x_value in [-13.0, -5.0, 3.0, 11.0]:
		for z_value in [-7.5, -1.0, 5.5]:
			_add_box(self, "Fluorescent_Fixture", Vector3(2.6, 0.09, 0.38), Vector3(x_value, 8.48, z_value), fluorescent)
			_add_light(self, Vector3(x_value, 7.85, z_value), Color(0.66, 0.86, 1.0), 1.05, 10.0)

	# A small warning beacon above the heavy gate.
	_add_box(self, "Gate_Warning_Beacon", Vector3(0.35, 0.24, 0.28), Vector3(5.4, 6.85, -5.0), warning_red)
	_add_light(self, Vector3(5.4, 6.55, -4.7), Color(1.0, 0.08, 0.035), 0.75, 4.0)


func _build_control_station() -> void:
	# A staffed monitoring desk on the otherwise unused right side of the room.
	_add_desk(self, Vector3(14.2, 0.0, 0.1), 6.8, 1.35, wood_material)
	_add_monitor(self, Vector3(12.0, 1.67, -0.42), screen_green, "CAM 01")
	_add_monitor(self, Vector3(14.2, 1.67, -0.42), screen_amber, "SUBJECT")
	_add_monitor(self, Vector3(16.4, 1.67, -0.42), screen_green, "CAM 04")

	for x_value in [12.0, 14.2, 16.4]:
		_add_box(self, "Control_Keyboard", Vector3(0.9, 0.045, 0.34), Vector3(x_value, 1.12, 0.72), dark_metal)
		_add_box(self, "Control_Keyboard_Light", Vector3(0.74, 0.012, 0.025), Vector3(x_value, 1.15, 0.72), screen_green)

	# File cabinets and a storage rack behind the operator's desk.
	for z_value in [3.1, 4.65]:
		_add_box(self, "Filing_Cabinet", Vector3(1.15, 2.1, 0.72), Vector3(17.4, 1.05, z_value), dark_metal)
		for y_value in [0.45, 1.05, 1.65]:
			_add_box(self, "Cabinet_Drawer_Front", Vector3(1.02, 0.045, 0.035), Vector3(17.4, y_value, z_value - 0.38), metal)
			_add_box(self, "Cabinet_Handle", Vector3(0.28, 0.035, 0.045), Vector3(17.4, y_value, z_value - 0.41), panel_cream)

	_add_box(self, "Wall_Monitor_Board", Vector3(4.6, 2.0, 0.14), Vector3(18.45, 4.4, 0.5), dark_metal)
	_add_box(self, "Wall_Monitor_Glass", Vector3(4.25, 1.65, 0.035), Vector3(18.36, 4.45, 0.5), screen_green)
	_add_label(self, "LIVE FEED  //  C-04", Vector3(18.30, 5.65, 0.5), -90.0, 18, Color(0.66, 1.0, 0.78))

	# Small props make the station feel used rather than like a showroom.
	_add_box(self, "Desk_Paper_Stack", Vector3(0.50, 0.045, 0.40), Vector3(11.3, 1.12, 0.55), panel_cream)
	_add_box(self, "Desk_Radio", Vector3(0.34, 0.22, 0.28), Vector3(17.0, 1.19, 0.65), dark_metal)
	_add_box(self, "Desk_Radio_Display", Vector3(0.19, 0.10, 0.025), Vector3(17.0, 1.20, 0.50), screen_amber)
	_add_box(self, "Operator_Chair_Seat", Vector3(0.85, 0.18, 0.78), Vector3(14.2, 0.75, 2.2), dark_metal)
	_add_box(self, "Operator_Chair_Back", Vector3(0.85, 1.0, 0.18), Vector3(14.2, 1.25, 2.58), dark_metal)

	_add_label(self, "MONITORING / CONTROL", Vector3(14.2, 3.0, -0.82), 0.0, 23, Color(0.91, 0.78, 0.48))
	_add_label(self, "STAFF USE ONLY", Vector3(14.2, 2.6, -0.82), 0.0, 13, Color(0.72, 0.85, 0.82))


func _build_security_cameras() -> void:
	# These are existing imported 3D assets from the repository, not placeholder cubes.
	_add_camera(self, Vector3(-18.0, 5.8, -7.8), 35.0, 0.34)
	_add_camera(self, Vector3(18.0, 5.8, -7.8), -145.0, 0.34)
	_add_camera(self, Vector3(18.0, 5.8, 6.4), -35.0, 0.34)

	var trash_instance := TRASHCAN_SCENE.instantiate()
	if trash_instance is Node3D:
		var trash_node := trash_instance as Node3D
		trash_node.name = "Office_Trashcans"
		trash_node.position = Vector3(17.0, 0.0, 6.0)
		trash_node.scale = Vector3.ONE * 0.9
		add_child(trash_node)


func _build_service_corridor() -> void:
	# This corridor continues beyond the original large gate, making the gate lead somewhere.
	_add_box(self, "Corridor_Floor", Vector3(8.45, 0.12, 13.7), Vector3(5.4, -0.045, -18.15), floor_material, true)
	_add_box(self, "Corridor_Left_Wall", Vector3(0.42, 8.5, 19.3), Vector3(1.12, 4.25, -15.0), wall_material, true)
	_add_box(self, "Corridor_Right_Wall_Near", Vector3(0.42, 8.5, 9.0), Vector3(9.68, 4.25, -10.0), wall_material, true)
	_add_box(self, "Corridor_Right_Wall_Far", Vector3(0.42, 8.5, 4.0), Vector3(9.68, 4.25, -22.8), wall_material, true)
	_add_box(self, "Corridor_Ceiling", Vector3(8.6, 0.3, 19.2), Vector3(5.4, 8.65, -15.0), dark_metal)

	_add_box(self, "Corridor_Left_Base_Trim", Vector3(0.14, 0.22, 18.8), Vector3(1.36, 0.2, -15.0), metal)
	_add_box(self, "Corridor_Right_Base_Trim", Vector3(0.14, 0.22, 18.8), Vector3(9.44, 0.2, -15.0), metal)
	_add_box(self, "Corridor_Safety_Line", Vector3(0.07, 0.016, 13.2), Vector3(2.0, 0.025, -18.1), yellow)
	_add_box(self, "Corridor_Safety_Line_2", Vector3(0.07, 0.016, 13.2), Vector3(8.8, 0.025, -18.1), yellow)

	for z_value in [-9.0, -14.0, -19.0, -24.0]:
		_add_box(self, "Corridor_Ceiling_Light", Vector3(3.0, 0.08, 0.32), Vector3(5.4, 8.43, z_value), fluorescent)
		_add_light(self, Vector3(5.4, 7.85, z_value), Color(0.70, 0.88, 1.0), 1.0, 9.0)

	_add_label(self, "OBSERVATION WING  ->", Vector3(5.4, 6.4, -9.2), 180.0, 25, Color(0.92, 0.78, 0.48))
	_add_label(self, "RESTRICTED ACCESS  //  C-04", Vector3(5.4, 5.9, -9.2), 180.0, 15, Color(0.78, 0.86, 0.82))

	# A heavy sealed bulkhead at the far end creates a believable sense of a larger facility.
	_add_box(self, "Corridor_End_Bulkhead", Vector3(8.5, 8.5, 0.45), Vector3(5.4, 4.25, -25.0), dark_metal, true)
	_add_box(self, "Bulkhead_Door_Left", Vector3(1.8, 5.8, 0.16), Vector3(4.45, 3.0, -24.72), metal)
	_add_box(self, "Bulkhead_Door_Right", Vector3(1.8, 5.8, 0.16), Vector3(6.35, 3.0, -24.72), metal)
	_add_box(self, "Bulkhead_Door_Seam", Vector3(0.05, 5.8, 0.04), Vector3(5.4, 3.0, -24.61), black)
	_add_label(self, "SEALED  //  SECTION C-05", Vector3(5.4, 6.4, -24.55), 180.0, 19, Color(0.88, 0.40, 0.28))


func _build_observation_lab() -> void:
	# A side laboratory is accessible from the opening in the corridor's right wall.
	_add_box(self, "Observation_Lab_Floor", Vector3(14.0, 0.12, 13.0), Vector3(17.0, -0.045, -18.5), floor_material, true)
	_add_box(self, "Observation_Lab_Ceiling", Vector3(14.2, 0.3, 13.2), Vector3(17.0, 8.65, -18.5), dark_metal)
	_add_box(self, "Observation_Lab_Outer_Wall", Vector3(0.42, 8.5, 13.0), Vector3(23.9, 4.25, -18.5), wall_material, true)
	_add_box(self, "Observation_Lab_Front_Wall", Vector3(14.0, 8.5, 0.42), Vector3(17.0, 4.25, -12.0), wall_material, true)
	_add_box(self, "Observation_Lab_Back_Wall", Vector3(14.0, 8.5, 0.42), Vector3(17.0, 4.25, -25.0), wall_material, true)

	# Large reinforced windows on the outer side.
	_add_box(self, "Lab_Observation_Glass", Vector3(0.07, 3.0, 7.0), Vector3(23.62, 4.8, -18.5), glass)
	_add_box(self, "Lab_Window_Top_Frame", Vector3(0.16, 0.16, 7.25), Vector3(23.56, 6.38, -18.5), metal)
	_add_box(self, "Lab_Window_Bottom_Frame", Vector3(0.16, 0.16, 7.25), Vector3(23.56, 3.22, -18.5), metal)
	for z_value in [-22.0, -18.5, -15.0]:
		_add_box(self, "Lab_Window_Mullion", Vector3(0.16, 3.15, 0.14), Vector3(23.56, 4.8, z_value), metal)

	_add_label(self, "BEHAVIORAL OBSERVATION LAB", Vector3(17.0, 7.25, -12.27), 0.0, 24, Color(0.88, 0.80, 0.58))
	_add_label(self, "SUBJECT MONITORING  //  ROOM 04-B", Vector3(17.0, 6.78, -12.27), 0.0, 14, Color(0.72, 0.88, 0.83))

	# Central examination table and instrument trolley.
	_add_box(self, "Examination_Table_Top", Vector3(5.2, 0.16, 1.7), Vector3(17.5, 1.05, -19.5), panel_cream)
	_add_box(self, "Examination_Table_Base", Vector3(4.8, 0.78, 1.35), Vector3(17.5, 0.48, -19.5), dark_metal)
	_add_box(self, "Examination_Table_Safety_Rail", Vector3(5.0, 0.10, 0.10), Vector3(17.5, 1.22, -20.25), metal)
	_add_box(self, "Instrument_Trolley_Top", Vector3(1.6, 0.10, 0.85), Vector3(21.0, 1.08, -21.6), metal)
	_add_box(self, "Instrument_Trolley_Lower_Shelf", Vector3(1.5, 0.08, 0.78), Vector3(21.0, 0.55, -21.6), metal)
	for x_offset in [-0.65, 0.65]:
		for z_offset in [-0.3, 0.3]:
			_add_cylinder(self, "Trolley_Leg", 0.88, 0.045, Vector3(21.0 + x_offset, 0.55, -21.6 + z_offset), dark_metal)

	# Side console with old CRT-style monitors.
	_add_desk(self, Vector3(13.0, 0.0, -15.5), 4.2, 1.0, wood_material)
	_add_monitor(self, Vector3(12.0, 1.67, -15.9), screen_amber, "REC 04-B")
	_add_monitor(self, Vector3(14.0, 1.67, -15.9), screen_green, "PULSE")
	_add_box(self, "Lab_Storage_Cabinet", Vector3(1.25, 2.5, 0.8), Vector3(22.2, 1.25, -13.9), dark_metal)
	_add_box(self, "Lab_Cabinet_Label", Vector3(0.9, 0.20, 0.025), Vector3(22.2, 1.95, -14.32), panel_cream)

	# The room has a second layer of cold fluorescent lighting.
	for x_value in [13.0, 18.0, 22.0]:
		_add_box(self, "Lab_Fluorescent_Fixture", Vector3(2.2, 0.08, 0.34), Vector3(x_value, 8.42, -18.5), fluorescent)
		_add_light(self, Vector3(x_value, 7.8, -18.5), Color(0.69, 0.88, 1.0), 1.1, 9.0)

	_add_camera(self, Vector3(23.1, 5.9, -12.9), -90.0, 0.34)
	_add_camera(self, Vector3(23.1, 5.9, -24.0), -90.0, 0.34)


func _build_entry_airlock() -> void:
	# Small staff vestibule behind the player spawn.
	_add_box(self, "Staff_Airlock_Floor", Vector3(8.0, 0.12, 10.0), Vector3(0.0, -0.045, 13.0), floor_material, true)
	_add_box(self, "Staff_Airlock_Left_Wall", Vector3(0.42, 8.3, 10.0), Vector3(-4.0, 4.15, 13.0), wall_material, true)
	_add_box(self, "Staff_Airlock_Right_Wall", Vector3(0.42, 8.3, 10.0), Vector3(4.0, 4.15, 13.0), wall_material, true)
	_add_box(self, "Staff_Airlock_End_Wall", Vector3(8.0, 8.3, 0.42), Vector3(0.0, 4.15, 18.0), wall_material, true)
	_add_box(self, "Staff_Airlock_Ceiling", Vector3(8.2, 0.28, 10.2), Vector3(0.0, 8.45, 13.0), dark_metal)

	_add_box(self, "Staff_Door_Left_Panel", Vector3(1.75, 5.8, 0.16), Vector3(-0.9, 2.9, 17.72), metal)
	_add_box(self, "Staff_Door_Right_Panel", Vector3(1.75, 5.8, 0.16), Vector3(0.9, 2.9, 17.72), metal)
	_add_box(self, "Staff_Door_Seam", Vector3(0.05, 5.8, 0.04), Vector3(0.0, 2.9, 17.60), black)
	_add_label(self, "HOLLOWAY  //  STAFF ENTRY", Vector3(0.0, 6.6, 17.55), 180.0, 21, Color(0.9, 0.78, 0.5))
	_add_label(self, "BADGE REQUIRED", Vector3(0.0, 5.95, 17.55), 180.0, 13, Color(0.9, 0.38, 0.27))

	for z_value in [10.2, 15.4]:
		_add_box(self, "Airlock_Fluorescent", Vector3(2.6, 0.08, 0.34), Vector3(0.0, 8.25, z_value), fluorescent)
		_add_light(self, Vector3(0.0, 7.65, z_value), Color(0.76, 0.88, 0.92), 0.9, 8.0)
