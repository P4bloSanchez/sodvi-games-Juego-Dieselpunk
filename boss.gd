extends CharacterBody2D

signal boss_derrotado

var MisilBoss = preload("res://scenes/misil_boss.tscn")

@onready var timer_disparo = $TimerDisparo
@onready var sprite_explosion = $SpriteEXPLOSION
@onready var patas = [$Pata1, $Pata2, $Pata3, $Pata4, $Pata5, $Pata6]

var vida = 50
var tiempo_fase = 0.0
var patron_actual = 0
var duracion_patron = 5.0

var velocidad_zigzag = 80.0
var direccion_zigzag = 1

var angulo_circular = 0.0
var radio_circular = 100.0
var centro_circular = Vector2(270, 80)
var velocidad_angular = 1.5

func _ready():
	timer_disparo.wait_time = 1.2
	timer_disparo.start()
	centro_circular = Vector2(270, 80)

func _process(delta):
	tiempo_fase += delta
	if tiempo_fase >= duracion_patron:
		tiempo_fase = 0.0
		patron_actual = (patron_actual + 1) % 2
	match patron_actual:
		0:
			_mover_zigzag(delta)
		1:
			_mover_circular(delta)

func _mover_zigzag(delta):
	position.x += velocidad_zigzag * direccion_zigzag * delta
	if position.x > 460:
		direccion_zigzag = -1
	elif position.x < 80:
		direccion_zigzag = 1

func _mover_circular(delta):
	angulo_circular += velocidad_angular * delta
	position.x = centro_circular.x + cos(angulo_circular) * radio_circular
	position.y = centro_circular.y + sin(angulo_circular) * radio_circular * 0.4

func explotar():
	vida -= 1
	if vida <= 0:
		_morir()
	else:
		modulate = Color(10, 1, 1)
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1)

func _morir():
	timer_disparo.stop()
	set_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = false
	sprite_explosion.visible = true
	boss_derrotado.emit()
	await get_tree().create_timer(1.5).timeout
	queue_free()
	
func _on_timer_disparo_timeout() -> void:
	_disparar_todas_patas()
	timer_disparo.wait_time = randf_range(0.8, 1.5)
	timer_disparo.start()
	
func _disparar_todas_patas():
	for pata in patas:
		if pata == null:
			continue
		var misil = MisilBoss.instantiate()
		misil.global_position = pata.global_position
		var dir = Vector2(randf_range(-0.3, 0.3), 1).normalized()
		get_parent().add_child(misil)
		misil.iniciar(dir)
