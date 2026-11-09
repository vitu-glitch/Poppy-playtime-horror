extends CanvasLayer

var scene_path: String

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func start() -> void:
	# Mostra a tela de loading antes de abrir a proxima cena.
	animation_player.play("start_load")
	await animation_player.animation_finished

	# Carregamento direto: evita ficar preso esperando o carregamento em thread.
	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		push_error("HOLLOWAY: Nao foi possivel carregar a cena: " + scene_path)
		queue_free()
		return

	var change_error := get_tree().change_scene_to_packed(packed_scene)
	if change_error != OK:
		push_error("HOLLOWAY: Falha ao abrir a cena: " + scene_path)
		queue_free()
		return

	_start_outro_animation()

func _start_outro_animation() -> void:
	get_tree().paused = false
	animation_player.play("end_load")
	await animation_player.animation_finished
	queue_free()
