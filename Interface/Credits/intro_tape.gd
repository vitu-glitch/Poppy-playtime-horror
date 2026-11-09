extends Control

var skip_amount: float = 0.0
@onready var ring: ColorRect = $ring
var finished: bool = false

func _ready() -> void:
	await Game.delay(1.0)
	$AnimationPlayer.play("hold")
	$VideoStreamPlayer.play()
	await $VideoStreamPlayer.finished
	_finish_intro()

func _process(delta: float) -> void:
	if finished: return
	
	if Input.is_action_pressed("jump"): skip_amount = move_toward(skip_amount, 1.0, 0.5*delta)
	else: skip_amount = move_toward(skip_amount, 0.0, 1.0*delta)
	
	var mat: ShaderMaterial = ring.material
	mat.set_shader_parameter("value", skip_amount)
	
	if skip_amount >= 1.0:
		_finish_intro()

func _finish_intro() -> void:
	if finished: return
	finished = true
	$VideoStreamPlayer.stop()
	Game.load_checkpoint()
