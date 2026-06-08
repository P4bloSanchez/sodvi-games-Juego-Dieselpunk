extends Area2D

var velocidad = Vector2.ZERO
const VELOCIDAD_BASE = 180

func iniciar(direccion: Vector2):
	"""
	Inicializa la dirección y velocidad del objeto.
	Se llama desde el script del emisor
	"""
	velocidad = direccion * VELOCIDAD_BASE

func _process(delta: float):
	position += velocidad * delta
	if position.y > 380 or position.y < -20 or position.x < -20 or position.x > 560:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") and body.has_method("explotar"):
		body.explotar()
		queue_free()
