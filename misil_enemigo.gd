extends Area2D

var speed = 150

func _process(delta):
	position.y += speed * delta
	
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("explotar") and body.is_in_group("jugador"):
		body.explotar()
		queue_free()
