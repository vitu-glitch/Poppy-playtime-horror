extends CanvasLayer

var scene_path: String
signal loading_screen_has_full_coverage

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var load_started: bool = false

func start() -> void:
	var request_error := ResourceLoader.load_threaded_request(scene_path)
	if request_error != OK:
		push_error("HOLLOWAY: Nao foi possivel iniciar o carregamento: " + scene_path)
		queue_free()
		return

	animation_player.play("start_load")
	await loading_screen_has_full_coverage
	load_started = true

func _process(_delta: float) -> void:
	if not load_started:
		return

	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(scene_path, progress)

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		load_started = false
		var packed_scene := ResourceLoader.load_threaded_get(scene_path) as PackedScene
		if packed_scene == null:
			push_error("HOLLOWAY: A cena carregou, mas o recurso PackedScene esta vazio: " + scene_path)
			queue_free()
			return

		var change_error := get_tree().change_scene_to_packed(packed_scene)
		if change_error != OK:
			push_error("HOLLOWAY: Falha ao abrir a cena: " + scene_path)
			queue_free()
			return
		_start_outro_animation()
	elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		load_started = false
		push_error("HOLLOWAY: Falha ao carregar a cena: " + scene_path)
		queue_free()

func _start_outro_animation() -> void:
	get_tree().paused = false
	animation_player.play("end_load")
	await Signal(animation_player, "animation_finished")
	queue_free()
