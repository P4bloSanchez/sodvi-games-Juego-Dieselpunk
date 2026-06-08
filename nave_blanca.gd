extends CharacterBody2D

signal nave_eliminada(referencia)

@onready var sprite_explosion = $SpriteEXPLOSION

var velocidad_y = 120.0

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
