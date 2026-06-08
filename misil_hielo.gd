extends Area2D

var velocidad = 200

func _process(delta):
	position.y -= velocidad * delta
	if position.y < -20:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("boss"):
		body.recibir_hielo()
		queue_free()
