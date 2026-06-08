extends CharacterBody2D

signal boss2_derrotado

var MisilFuego = preload("res://scenes/misil_fuego.tscn")

@onready var timer_disparo = $TimerDisparo
@onready var timer_rafaga = $TimerRafaga
@onready var sprite_explosion = $SpriteEXPLOSION
@onready var patas = [$Pata1, $Pata2, $Pata3, $Pata4]
@onready var canon_central = $Pata5

var vida = 150
var tiempo_movimiento = 0.0
var rafaga_contador = 0
var en_rafaga = false
var fase2_activa = false

func _ready():
	timer_disparo.wait_time = 1.2
	timer_disparo.start()
	timer_rafaga.wait_time = 2.0
	timer_rafaga.start()

func _process(delta):
	tiempo_movimiento += delta
	if fase2_activa:
		position.x = 270 + sin(tiempo_movimiento * 5.0) * 140 + sin(tiempo_movimiento * 7.3) * 40 + sin(tiempo_movimiento * 11.2) * 15
		position.y = 80 + sin(tiempo_movimiento * 3.2) * 45 + sin(tiempo_movimiento * 5.8) * 20 + sin(tiempo_movimiento * 9.1) * 10
	else:
		position.x = 270 + sin(tiempo_movimiento * 3.0) * 140 + sin(tiempo_movimiento * 4.6) * 40 + sin(tiempo_movimiento * 8.2) * 15
		position.y = 80 + sin(tiempo_movimiento * 1.8) * 45 + sin(tiempo_movimiento * 3.4) * 20 + sin(tiempo_movimiento * 6.6) * 10

func explotar():
	vida -= 1
	if vida <= 50 and not fase2_activa:
		fase2_activa = true
		timer_disparo.wait_time = 0.4
		timer_disparo.start()
	if vida <= 0:
		_morir()
	else:
		modulate = Color(10, 1, 1)
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1)

func _morir():
	timer_disparo.stop()
	timer_rafaga.stop()
	set_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = false
	sprite_explosion.visible = true
	boss2_derrotado.emit()
	await get_tree().create_timer(1.5).timeout
	queue_free()

func _on_timer_disparo_timeout():
	_disparar_todas_patas()
	timer_disparo.wait_time = randf_range(0.4, 0.8) if fase2_activa else randf_range(0.8, 1.5)
	timer_disparo.start()

func _on_timer_rafaga_timeout():
	if en_rafaga:
		var misil = MisilFuego.instantiate()
		misil.global_position = canon_central.global_position
		get_parent().add_child(misil)
		misil.iniciar(Vector2(0, 1))
		rafaga_contador += 1
		var limite_rafaga = 8 if fase2_activa else 5
		var pausa_rafaga = 0.05 if fase2_activa else 0.15
		var pausa_entre = randf_range(0.8, 1.5) if fase2_activa else 2.0
		if rafaga_contador >= limite_rafaga:
			en_rafaga = false
			rafaga_contador = 0
			timer_rafaga.wait_time = pausa_entre
		else:
			timer_rafaga.wait_time = pausa_rafaga
	else:
		en_rafaga = true
		rafaga_contador = 0
		timer_rafaga.wait_time = 0.05 if fase2_activa else 0.15
	timer_rafaga.start()

func _disparar_todas_patas():
	for pata in patas:
		if pata == null:
			continue
		var misil = MisilFuego.instantiate()
		misil.global_position = pata.global_position
		var dir = Vector2(randf_range(-0.3, 0.3), 1).normalized()
		get_parent().add_child(misil)
		misil.iniciar(dir)
