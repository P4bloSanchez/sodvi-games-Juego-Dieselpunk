extends Node
var Enemigo = preload("res://scenes/enemigo.tscn")
@onready var timer_disparo = $TimerDISPARAR
@onready var timer_descender = $TimerDESCENDER
var Boss = preload("res://scenes/boss.tscn")
var lista_enemigos = []
var direccion_vertical = 1 
var limite_inferior = 300  
var limite_superior = 30 

var oleada_actual = 0
var tiempos_descenso = [15.0, 7.0, 5.0, 3.0]
var tiempos_disparo_min = [1.5, 0.8, 0.4, 0.2]  
var tiempos_disparo_max = [3.0, 1.5, 0.8, 0.4]  
var enemigos_vivos = 0

var solo_boss = false

func _ready():
	if GameState.solo_boss:
		GameState.solo_boss = false
		await get_tree().create_timer(1.0).timeout
		_invocar_boss()
	else:
		iniciar_oleada()
	
func iniciar_oleada():
	lista_enemigos.clear()
	direccion_vertical = 1

	var tiempo_desc = tiempos_descenso[min(oleada_actual, tiempos_descenso.size() - 1)]
	timer_descender.wait_time = tiempo_desc
	timer_descender.start()

	var idx = min(oleada_actual, tiempos_disparo_min.size() - 1)
	timer_disparo.wait_time = tiempos_disparo_max[idx]
	timer_disparo.start()

	print("Oleada %d — descenso: %.1fs  disparo: %.1f-%.1fs" % [
		oleada_actual + 1, tiempo_desc,
		tiempos_disparo_min[idx], tiempos_disparo_max[idx]
	])

	enemigos_vivos = 0
	for j in range(4):
		lista_enemigos.append([])
		for i in range(9):
			var enemigo = Enemigo.instantiate()
			enemigo.global_position = Vector2(80 + 50 * i, 30 + 40 * j)
			self.add_child(enemigo)
			enemigo.activar_sprite_por_fila(j)
			enemigo.enemigo_eliminado.connect(_on_enemigo_eliminado)
			lista_enemigos[j].append(enemigo)
			enemigos_vivos += 1

func _on_enemigo_eliminado(nave_muerta):
	for fila in range(len(lista_enemigos)):
		for col in range(len(lista_enemigos[fila])):
			if lista_enemigos[fila][col] == nave_muerta:
				lista_enemigos[fila][col] = null 
				break
				
	enemigos_vivos -= 1
	
	print("Enemigos restantes: %d" % enemigos_vivos)
	revisar_y_cerrar_columnas_vacias()
	
	if enemigos_vivos <= 0:
		oleada_actual += 1
		timer_descender.stop()
		timer_disparo.stop()
		var jugador = get_tree().get_first_node_in_group("jugador")
		if jugador and is_instance_valid(jugador):
			jugador.reiniciar_vida()
		if oleada_actual >= 4:
			await get_tree().create_timer(3.0).timeout
			_invocar_boss()
		else:
			await get_tree().create_timer(2.0).timeout
			iniciar_oleada()

func _invocar_boss():
	var boss = Boss.instantiate()
	boss.global_position = Vector2(270, 60)
	boss.boss_derrotado.connect(_on_boss_derrotado)
	get_parent().add_child(boss)

func _on_boss_derrotado():
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/main2.tscn")

func revisar_y_cerrar_columnas_vacias():
	for col in range(8, -1, -1):
		var columna_vacia = true
		for fila in range(len(lista_enemigos)):
			if lista_enemigos[fila][col] != null and is_instance_valid(lista_enemigos[fila][col]):
				columna_vacia = false
				break
		if columna_vacia:
			print("¡Columna vacía detectada! Moviendo escuadrón con física real...")
			for fila in range(len(lista_enemigos)):
				for c_der in range(8, col, -1):
					var enemigo_a_mover = lista_enemigos[fila][c_der]
					if enemigo_a_mover != null and is_instance_valid(enemigo_a_mover):
						if enemigo_a_mover.tiene_obstaculo_izq():
							continue
						enemigo_a_mover.position.x -= 50
			for fila in range(len(lista_enemigos)):
				lista_enemigos[fila].remove_at(col)
				lista_enemigos[fila].append(null)

func _on_timer_descender_timeout() -> void:
	var y_mas_bajo = -INF
	var y_mas_alto = INF
	for fila in lista_enemigos:
		for a in fila:
			if is_instance_valid(a):
				if a.position.y > y_mas_bajo:
					y_mas_bajo = a.position.y
				if a.position.y < y_mas_alto:
					y_mas_alto = a.position.y
	if y_mas_bajo >= limite_inferior:
		direccion_vertical = -1
	elif y_mas_alto <= limite_superior:
		direccion_vertical = 1
	for fila in lista_enemigos:
		for a in fila:
			if is_instance_valid(a):
				a.position.y += (21 * direccion_vertical)

func _on_timer_disparar_timeout() -> void:
	var lista_enemigos_vivos = []
	for fila in lista_enemigos:
		for a in fila:
			if is_instance_valid(a) and !a.is_queued_for_deletion():
				lista_enemigos_vivos.append(a)
	if lista_enemigos_vivos:
		var indice = int(floor(randf_range(0,len(lista_enemigos_vivos)-1)))
		lista_enemigos_vivos[indice].disparar()
		var idx = min(oleada_actual, tiempos_disparo_min.size() - 1)
		timer_disparo.wait_time = randf_range(tiempos_disparo_min[idx], tiempos_disparo_max[idx])
