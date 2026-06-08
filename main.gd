extends Node

@onready var fondo_infinito = $ParallaxBackground
var velocidad_fondo = 80 

func _process(delta: float) -> void:
	fondo_infinito.scroll_offset.y += velocidad_fondo * delta
