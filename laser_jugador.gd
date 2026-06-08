extends Area2D

var velocidad = 200

func _process(delta):
	position.y -= velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos"):
		body.explotar() # Esto arranca la explosión en el enemigo
		queue_free()
		 
