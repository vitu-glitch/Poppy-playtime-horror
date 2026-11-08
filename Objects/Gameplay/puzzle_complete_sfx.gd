extends Node
class_name CompletePuzzleSound

@export var signal_name: String = "powered"

const SW_PUZZLE_COMPLETE_STEREO = preload("uid://ddlwgurnc3377")

func _ready() -> void:
	get_parent().connect(signal_name, play)
func play():
	GlobalSound.quick_local_sfx(SW_PUZZLE_COMPLETE_STEREO)
