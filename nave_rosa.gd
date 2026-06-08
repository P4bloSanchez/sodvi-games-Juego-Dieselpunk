extends CharacterBody2D

signal nave_eliminada(referencia)

var MisilRosa = preload("res://scenes/misil_enemigo.tscn")

@onready var timer_disparo = $TimerDisparo
@onready var spawn1 = $SpawnMisil1
@onready var spawn2 = $SpawnMisil2
@onready var sprite_explosion = $SpriteEXPLOSION


var velocidad_y = 60.0

func _ready():
	timer_disparo.wait_time = randf_range(0.8, 1.5)
	timer_disparo.start()

func _process(delta):
	position.y += velocidad_y * delta
	if position.y > 380:
		queue_free()

func explotar():
	nave_eliminada.emit(self)
	$CollisionShape2D.set_deferred("disabled", true)
	$SPRITE.visible = false
	sprite_explosion.visible = true
	modulate = Color(1, 1, 1)
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_timer_disparo_timeout():
	_disparar()
	timer_disparo.wait_time = randf_range(0.8, 1.5)
	timer_disparo.start()

func _disparar():
	var misil1 = MisilRosa.instantiate()
	misil1.global_position = spawn1.global_position
	get_parent().add_child(misil1)

	var misil2 = MisilRosa.instantiate()
	misil2.global_position = spawn2.global_position
	get_parent().add_child(misil2)
