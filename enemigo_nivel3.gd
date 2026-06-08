extends CharacterBody2D

signal enemigo_eliminado(referencia)

var MisilEnemigo = preload("res://scenes/misil_enemigo.tscn")

@onready var sprite_nave1 = $SpriteNAVE1
@onready var sprite_nave2 = $SpriteNAVE2
@onready var sprite_nave3 = $SpriteNAVE3
@onready var sprite_explosion = $SpriteEXPLOSION
@onready var timer_disparo = $TimerDisparo
@onready var spawn1 = $SpawnMisil1
@onready var spawn2 = $SpawnMisil2

var vida = 3
var tipo_movimiento = 0  # 0=suave, 1=agresiva, 2=aleatoria
var posicion_formacion = Vector2.ZERO
var en_formacion = true
var tiempo = 0.0
var atacando = false
var regresando = false

# Curva suave
var progreso_curva = 0.0
var velocidad_curva = 0.8
var puntos_curva = []

func activar_sprite_por_fila(num_fila: int):
	sprite_nave1.visible = false
	sprite_nave2.visible = false
	sprite_nave3.visible = false
	if num_fila == 0 or num_fila == 1:
		sprite_nave1.visible = true
		tipo_movimiento = 0
	elif num_fila == 2:
		sprite_nave2.visible = true
		tipo_movimiento = 1
	elif num_fila == 3:
		sprite_nave3.visible = true
		tipo_movimiento = 2

func guardar_posicion_formacion():
	posicion_formacion = global_position

func iniciar_ataque():
	if atacando or regresando:
		return
	atacando = true
	en_formacion = false
	progreso_curva = 0.0
	_generar_curva()
	timer_disparo.wait_time = randf_range(0.5, 1.0)
	timer_disparo.start()

func _generar_curva():
	var inicio = global_position
	var destino = Vector2(randf_range(60, 480), 320)
	match tipo_movimiento:
		0:  # Suave - curva S elegante
			puntos_curva = [
				inicio,
				Vector2(inicio.x + randf_range(-80, 80), inicio.y + 80),
				Vector2(destino.x + randf_range(-60, 60), destino.y - 80),
				destino
			]
		1:  # Agresiva - loop antes de bajar
			puntos_curva = [
				inicio,
				Vector2(inicio.x + randf_range(-120, 120), inicio.y - 60),
				Vector2(inicio.x + randf_range(-100, 100), inicio.y + 40),
				Vector2(destino.x + randf_range(-80, 80), destino.y - 60),
				destino
			]
		2:  # Aleatoria - impredecible
			puntos_curva = [
				inicio,
				Vector2(randf_range(40, 500), randf_range(50, 200)),
				Vector2(randf_range(40, 500), randf_range(150, 280)),
				destino
			]

func _process(delta):
	tiempo += delta
	if atacando:
		progreso_curva += delta * velocidad_curva
		if progreso_curva >= 1.0:
			progreso_curva = 1.0
			atacando = false
			regresando = true
			progreso_curva = 0.0
			_generar_curva_regreso()
		else:
			global_position = _bezier(puntos_curva, progreso_curva)
	elif regresando:
		progreso_curva += delta * velocidad_curva
		if progreso_curva >= 1.0:
			global_position = posicion_formacion
			regresando = false
			en_formacion = true
			timer_disparo.stop()
		else:
			global_position = _bezier(puntos_curva, progreso_curva)

func _generar_curva_regreso():
	var inicio = global_position
	puntos_curva = [
		inicio,
		Vector2(inicio.x + randf_range(-60, 60), inicio.y - 80),
		Vector2(posicion_formacion.x + randf_range(-40, 40), posicion_formacion.y + 80),
		posicion_formacion
	]

func _bezier(puntos: Array, t: float) -> Vector2:
	var n = puntos.size() - 1
	var resultado = Vector2.ZERO
	for i in range(puntos.size()):
		var coef = _binomial(n, i) * pow(1 - t, n - i) * pow(t, i)
		resultado += puntos[i] * coef
	return resultado

func _binomial(n: int, k: int) -> float:
	if k == 0 or k == n:
		return 1.0
	var resultado = 1.0
	for i in range(k):
		resultado *= float(n - i) / float(i + 1)
	return resultado

func explotar():
	vida -= 1
	if vida <= 0:
		timer_disparo.stop()
		enemigo_eliminado.emit(self)
		$CollisionShape2D.set_deferred("disabled", true)
		sprite_nave1.visible = false
		sprite_nave2.visible = false
		sprite_nave3.visible = false
		sprite_explosion.visible = true
		await get_tree().create_timer(0.5).timeout
		queue_free()
	else:
		modulate = Color(10, 1, 1)
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1)

func _on_timer_disparo_timeout():
	if atacando:
		_disparar()
		timer_disparo.wait_time = randf_range(0.5, 1.2)
		timer_disparo.start()

func _disparar():
	var misil1 = MisilEnemigo.instantiate()
	misil1.global_position = spawn1.global_position
	get_parent().add_child(misil1)
	var misil2 = MisilEnemigo.instantiate()
	misil2.global_position = spawn2.global_position
	get_parent().add_child(misil2)
