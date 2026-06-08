extends CharacterBody2D

signal boss3_derrotado

var MisilFuego = preload("res://scenes/misil_fuego.tscn")
var ItemHielo = preload("res://scenes/item_hielo.tscn")

@onready var timer_disparo = $TimerDisparo
@onready var timer_item = $TimerItem
@onready var sprite_explosion = $SpriteEXPLOSION
@onready var patas = [$Pata1, $Pata2, $Pata3, $Pata4, $Pata5, $Pata6, $Pata7, $Pata8, $Pata9, $Pata10]

var vida = 500
var tiempo_movimiento = 0.0
var congelado = false
var contar_hielo = 0
var fase2_activa = false
var fase3_activa = false

func _ready():
	timer_disparo.wait_time = 1.5
	timer_disparo.start()
	timer_item.wait_time = 90.0
	timer_item.start()

func _process(delta):
	if congelado:
		return
	tiempo_movimiento += delta
	
	var velocidad_base = 0.6 + ((500 - vida) / 100.0) * 0.2
	
	if fase3_activa:
		position.x = 270 + sin(tiempo_movimiento * 2.1 * velocidad_base) * 160 + sin(tiempo_movimiento * 3.9 * velocidad_base) * 50 + sin(tiempo_movimiento * 5.7 * velocidad_base) * 20
		position.y = 80 + sin(tiempo_movimiento * 1.7 * velocidad_base) * 70 + sin(tiempo_movimiento * 3.2 * velocidad_base) * 30 + sin(tiempo_movimiento * 4.9 * velocidad_base) * 15
	elif fase2_activa:
		position.x = 270 + sin(tiempo_movimiento * 1.5 * velocidad_base) * 150 + sin(tiempo_movimiento * 2.7 * velocidad_base) * 45 + sin(tiempo_movimiento * 4.1 * velocidad_base) * 18
		position.y = 80 + sin(tiempo_movimiento * 1.1 * velocidad_base) * 60 + sin(tiempo_movimiento * 2.3 * velocidad_base) * 25 + sin(tiempo_movimiento * 3.5 * velocidad_base) * 12
	else:
		position.x = 270 + sin(tiempo_movimiento * 1.0 * velocidad_base) * 140 + sin(tiempo_movimiento * 1.9 * velocidad_base) * 40 + sin(tiempo_movimiento * 3.1 * velocidad_base) * 15
		position.y = 80 + sin(tiempo_movimiento * 0.7 * velocidad_base) * 50 + sin(tiempo_movimiento * 1.5 * velocidad_base) * 22 + sin(tiempo_movimiento * 2.3 * velocidad_base) * 10

func recibir_hielo():
	contar_hielo += 1
	modulate = Color(0.3, 0.7, 1.0)
	if contar_hielo >= 5:
		contar_hielo = 0
		_congelar()

func _congelar():
	congelado = true
	timer_disparo.stop()
	modulate = Color(0.0, 0.5, 1.0)
	await get_tree().create_timer(10.0).timeout
	if is_instance_valid(self):
		congelado = false
		modulate = Color(1, 1, 1)
		timer_disparo.wait_time = 0.6
		timer_disparo.start()

func explotar():
	if congelado:
		vida -= 1
	else:
		vida -= 1
	if vida <= 250 and not fase2_activa:
		fase2_activa = true
		timer_disparo.wait_time = 1.0
	if vida <= 100 and not fase3_activa:
		fase3_activa = true
		timer_disparo.wait_time = 0.6
	if vida <= 0:
		_morir()
	else:
		if not congelado:
			modulate = Color(10, 1, 1)
			await get_tree().create_timer(0.1).timeout
			modulate = Color(1, 1, 1)

func _morir():
	timer_disparo.stop()
	timer_item.stop()
	set_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = false
	sprite_explosion.visible = true
	boss3_derrotado.emit()
	await get_tree().create_timer(1.5).timeout
	queue_free()

func _on_timer_disparo_timeout():
	if congelado:
		return
	_disparar_todas_patas()
	timer_disparo.start()

func _disparar_todas_patas():
	for i in range(patas.size()):
		var pata = patas[i]
		if pata == null:
			continue
		var misil = MisilFuego.instantiate()
		misil.global_position = pata.global_position
		# Cada pata dispara en un ángulo diferente más abierto
		var angulo = -2.5 + (5.0 / (patas.size() - 1)) * i
		var dir = Vector2(angulo, 1).normalized()
		get_parent().add_child(misil)
		misil.iniciar(dir)

func _on_timer_item_timeout():
	var item = ItemHielo.instantiate()
	item.global_position = Vector2(randf_range(60, 480), 0)
	get_parent().add_child(item)
	timer_item.wait_time = 90.0
	timer_item.start()

