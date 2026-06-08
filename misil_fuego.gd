extends Area2D

var velocidad = Vector2.ZERO

func iniciar(direccion: Vector2):
	velocidad = direccion * 200

func _process(delta):
	position += velocidad * delta
	if position.y > 380 or position.y < -20 or position.x < -20 or position.x > 560:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") and body.has_method("explotar"):
		body.explotar(25)
		queue_free()
