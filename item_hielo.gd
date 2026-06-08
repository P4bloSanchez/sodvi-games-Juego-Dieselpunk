extends Area2D

var velocidad = 60.0

func _process(delta):
	position.y += velocidad * delta
	if position.y > 380:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		body.activar_poder_hielo()
		queue_free()
