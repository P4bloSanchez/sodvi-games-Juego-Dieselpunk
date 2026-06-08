extends Node

var Enemigo3 = preload("res://scenes/enemigo_2.tscn")

var lista_enemigos = []
var enemigos_vivos = 0
var oleada_actual = 0

@onready var timer_ataque = $TimerAtaque
@onready var timer_movimiento = $TimerMovimiento

var naves_por_ataque = [1, 2, 3]
var intervalo_ataque = [3.0, 2.0, 1.2]

var direccion_horizontal = 1
var limite_derecho = 480
var limite_izquierdo = 80
var paso_horizontal = 1

var Boss3 = preload("res://scenes/boss_3.tscn")
var boss_invocado = false

var solo_boss = false

func _ready():
	if GameState.solo_boss:
		GameState.solo_boss = false
		await get_tree().create_timer(1.0).timeout
		_invocar_boss()
	else:
		iniciar_oleada()
		timer_movimiento.wait_time = 0.01
		timer_movimiento.start()
	
func iniciar_oleada():
	lista_enemigos.clear()
	enemigos_vivos = 0
	var idx = min(oleada_actual, intervalo_ataque.size() - 1)
	timer_ataque.wait_time = intervalo_ataque[idx]
	timer_ataque.start()
	print("Oleada %d" % (oleada_actual + 1))
	for j in range(4):
		lista_enemigos.append([])
		for i in range(9):
			var enemigo = Enemigo3.instantiate()
			enemigo.global_position = Vector2(80 + 50 * i, 30 + 40 * j)
			self.add_child(enemigo)
			enemigo.activar_sprite_por_fila(j)
			enemigo.guardar_posicion_formacion()
			enemigo.enemigo_eliminado.connect(_on_enemigo_eliminado)
			lista_enemigos[j].append(enemigo)
			enemigos_vivos += 1

func _on_timer_ataque_timeout():
	var idx = min(oleada_actual, naves_por_ataque.size() - 1)
	var cantidad = naves_por_ataque[idx]
	var disponibles = []
	for fila in lista_enemigos:
		for enemigo in fila:
			if enemigo != null and is_instance_valid(enemigo) and enemigo.en_formacion:
				disponibles.append(enemigo)
	disponibles.shuffle()
	var a_atacar = min(cantidad, disponibles.size())
	for i in range(a_atacar):
		disponibles[i].iniciar_ataque()
	timer_ataque.wait_time = intervalo_ataque[min(oleada_actual, intervalo_ataque.size() - 1)]
	timer_ataque.start()

func _on_enemigo_eliminado(nave_muerta):
	for fila in range(len(lista_enemigos)):
		for col in range(len(lista_enemigos[fila])):
			if lista_enemigos[fila][col] == nave_muerta:
				lista_enemigos[fila][col] = null
				break
	enemigos_vivos -= 1
	print("Enemigos restantes: %d" % enemigos_vivos)
	if enemigos_vivos <= 0:
		oleada_actual += 1
		timer_ataque.stop()
		timer_movimiento.stop()
		var jugador = get_tree().get_first_node_in_group("jugador")
		if jugador and is_instance_valid(jugador):
			jugador.reiniciar_vida()
		if oleada_actual >= 3:
			await get_tree().create_timer(3.0).timeout
			_invocar_boss()
		else:
			await get_tree().create_timer(2.0).timeout
			iniciar_oleada()

func _invocar_boss():
	if boss_invocado:
		return
	boss_invocado = true
	var boss = Boss3.instantiate()
	boss.global_position = Vector2(270, 60)
	boss.boss3_derrotado.connect(_on_boss3_derrotado)
	get_parent().add_child(boss)

func _on_boss3_derrotado():
	await get_tree().create_timer(2.0).timeout
	print("¡Juego completado!")

var rango_movimiento = 60  # cuántos píxeles se mueve a cada lado

func _on_timer_movimiento_timeout():
	var x_mas_derecha = -INF
	var x_mas_izquierda = INF
	for fila in lista_enemigos:
		for enemigo in fila:
			if enemigo != null and is_instance_valid(enemigo) and enemigo.en_formacion:
				if enemigo.global_position.x > x_mas_derecha:
					x_mas_derecha = enemigo.global_position.x
				if enemigo.global_position.x < x_mas_izquierda:
					x_mas_izquierda = enemigo.global_position.x

	if x_mas_derecha >= limite_derecho + rango_movimiento:
		direccion_horizontal = -1
	elif x_mas_izquierda <= limite_izquierdo - rango_movimiento:
		direccion_horizontal = 1

	for fila in lista_enemigos:
		for enemigo in fila:
			if enemigo != null and is_instance_valid(enemigo):
				enemigo.posicion_formacion.x += paso_horizontal * direccion_horizontal
				if enemigo.en_formacion:
					enemigo.global_position.x += paso_horizontal * direccion_horizontal
