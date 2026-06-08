extends Node

var NaveRosa = preload("res://scenes/nave_rosa.tscn")
var NaveBlanca = preload("res://scenes/nave_blanca.tscn")
var Boss2 = preload("res://scenes/boss2.tscn")

@onready var timer_spawn = $TimerSpawn
@onready var timer_nivel = $TimerNivel

var tiempo_transcurrido = 0.0
var duracion_nivel = 300.0
var boss_invocado = false

# Dificultad inicial
var intervalo_spawn = 1.2
var velocidad_rosas = 60.0
var velocidad_blancas = 350.0
var cantidad_grupo = 2  

var solo_boss = false

func _ready():
	if GameState.solo_boss:
		GameState.solo_boss = false
		await get_tree().create_timer(1.0).timeout
		_invocar_boss()
	else:
		timer_spawn.wait_time = intervalo_spawn
		timer_spawn.start()
		timer_nivel.wait_time = duracion_nivel
		timer_nivel.start()

func _process(delta):
	tiempo_transcurrido += delta
	var nivel_dificultad = int(tiempo_transcurrido / 30.0)
	intervalo_spawn = max(0.3, 1.2 - nivel_dificultad * 0.15)
	velocidad_rosas = min(180.0, 60.0 + nivel_dificultad * 15.0)
	velocidad_blancas = min(500.0, 350.0 + nivel_dificultad * 20.0)
	cantidad_grupo = min(5, 2 + int(nivel_dificultad / 2))

func _on_timer_spawn_timeout():
	for i in range(cantidad_grupo):
		var rosa = NaveRosa.instantiate()
		var x = randf_range(100, 440)
		if randf() > 0.6:
			x = randf_range(200, 340) 
		rosa.global_position = Vector2(x, randf_range(-80, -10))
		rosa.velocidad_y = velocidad_rosas
		get_parent().add_child(rosa)
		
	var num_blancas = 1
	if randf() > 0.5:
		num_blancas = 2
	if randf() > 0.8:
		num_blancas = 3
	for i in range(num_blancas):
		var blanca = NaveBlanca.instantiate()
		blanca.global_position = Vector2(randf_range(40, 500), randf_range(-80, -10))
		blanca.velocidad_y = velocidad_blancas
		get_parent().add_child(blanca)

	timer_spawn.wait_time = intervalo_spawn
	timer_spawn.start()

func _on_timer_nivel_timeout():
	timer_spawn.stop()
	_limpiar_pantalla()
	await get_tree().create_timer(3.0).timeout
	_invocar_boss()

func _limpiar_pantalla():
	for nave in get_tree().get_nodes_in_group("enemigos"):
		if is_instance_valid(nave) and not nave.is_in_group("boss"):
			nave.queue_free()

func _invocar_boss():
	if boss_invocado:
		return
	boss_invocado = true
	timer_spawn.stop()
	_limpiar_pantalla()
	await get_tree().create_timer(1.0).timeout
	var boss = Boss2.instantiate()
	boss.global_position = Vector2(270, 60)
	boss.boss2_derrotado.connect(_on_boss2_derrotado)
	get_parent().add_child(boss)
	
func _on_boss2_derrotado():
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/main3.tscn")
