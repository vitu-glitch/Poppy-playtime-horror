extends Node
##Allows you to add a lightning-like effect to the hand when the hand is disabled. Effect replaces the Next Pass of a MeshInstance3D's surface override material.
class_name HandDisableParticles

const HAND_DISABLE_PARTICLES = preload("uid://ynv5bqxdxt2l")

@export var add_effect_to_mesh: MeshInstance3D
@export var surface_override: int = 0
@export var light_colour: Color = Color.CYAN

func enable():
	if add_effect_to_mesh:
		if not get_parent().has_node("DisableLight"):
			var new_light: OmniLight3D = OmniLight3D.new()
			new_light.light_color = light_colour
			new_light.name = "DisableLight"
			new_light.position.y += 0.018
			new_light.position.z += -0.043
			new_light.omni_range = 0.4
			get_parent().add_child(new_light)
		if add_effect_to_mesh.get_surface_override_material(0):
			add_effect_to_mesh.get_surface_override_material(0).next_pass = HAND_DISABLE_PARTICLES
func disable():
	if add_effect_to_mesh:
		if get_parent().has_node("DisableLight"): get_parent().get_node("DisableLight").queue_free()
		if add_effect_to_mesh.get_surface_override_material(0):
			add_effect_to_mesh.get_surface_override_material(0).next_pass = null
