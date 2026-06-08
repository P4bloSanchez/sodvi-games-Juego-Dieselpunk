extends CharacterBody2D
signal enemigo_eliminado(referencia_enemigo)
var Misil = preload("res://scenes/misil_enemigo.tscn")
@onready var timer_movimiento = $Timer_movimiento
@onready var sprite_explosion = $SpriteEXPLOSION
@onready var spawn_izquierdo = $SpawnPoint
@onready var spawn_derecho = $SpawnPoint2
var origen = 0
var rango = 40
var paso = 7
var direccion = 1
var vida = 2
var rayo_izq: RayCast2D

func _ready():
	timer_movimiento.start()
	origen = self.position.x
	rayo_izq = RayCast2D.new()
	add_child(rayo_izq)
	rayo_izq.target_position = Vector2(-45, 0)
	rayo_izq.enabled = true
	rayo_izq.collide_with_areas = true
	rayo_izq.collide_with_bodies = true

func _on_timer_movimiento_timeout() -> void:
	self.position.x += paso * direccion
	if self.position.x >= rango + origen or self.position.x < origen - rango:
		direccion *= -1

func explotar():
	vida -= 1
	if vida <= 0:
		timer_movimiento.stop()
		$CollisionShape2D.set_deferred("disabled", true)
		$SpriteENEMIGO.visible = false
		$SpriteENEMIGO2.visible = false
		$SpriteENEMIGO3.visible = false
		sprite_explosion.visible = true
		enemigo_eliminado.emit(self)
		await get_tree().create_timer(0.5).timeout
		queue_free()
	else:
		modulate = Color(10, 1, 1) 
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1)

func _on_timer_disparar_timeout() -> void:
	pass

func activar_sprite_por_fila(num_fila: int):
	$SpriteENEMIGO.visible = false
	$SpriteENEMIGO2.visible = false
	$SpriteENEMIGO3.visible = false
	if num_fila == 2 or num_fila == 3:
		$SpriteENEMIGO.visible = true
	elif num_fila == 1:
		$SpriteENEMIGO2.visible = true
	elif num_fila == 0:
		$SpriteENEMIGO3.visible = true

func disparar():
	var misil_izq = Misil.instantiate()
	misil_izq.global_position = spawn_izquierdo.global_position
	get_parent().add_child(misil_izq)
	var misil_der = Misil.instantiate()
	misil_der.global_position = spawn_derecho.global_position
	get_parent().add_child(misil_der)

func tiene_obstaculo_izq() -> bool:
	if rayo_izq == null:
		return false
	if rayo_izq.is_colliding():
		var colisionador = rayo_izq.get_collider()
		if colisionador != self:
			return true
	return false
