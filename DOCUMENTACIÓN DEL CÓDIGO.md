*boss.gd*

extends CharacterBody2D  # Permite controlar físicas y movimiento del jefe

signal boss_derrotado  # Se activa cuando el jefe muere para avisar al juego

var MisilBoss = preload("res://scenes/misil_boss.tscn")  # Carga la escena del misil que disparará el jefe

@onready var timer_disparo = $TimerDisparo  # Temporizador que controla cada cuánto dispara el jefe

@onready var sprite_explosion = $SpriteEXPLOSION  # Imagen de explosión que se muestra al morir

@onready var patas = [$Pata1, $Pata2, $Pata3, $Pata4, $Pata5, $Pata6]  # Lista de las seis patas del jefe

var vida = 50  # Puntos de vida del jefe, cada golpe resta 1

var tiempo_fase = 0.0  # Acumula el tiempo para saber cuándo cambiar de patrón de movimiento

var patron_actual = 0  # 0 significa movimiento zigzag, 1 significa movimiento circular

var duracion_patron = 5.0  # Cada patrón de movimiento dura 5 segundos antes de cambiar

var velocidad_zigzag = 80.0  # Qué tan rápido se mueve el jefe en el patrón zigzag

var direccion_zigzag = 1  # 1 es moverse a la derecha, -1 es moverse a la izquierda

var angulo_circular = 0.0  # Ángulo actual del movimiento circular, aumenta con el tiempo

var radio_circular = 100.0  # Tamaño del círculo que dibuja el jefe al moverse

var centro_circular = Vector2(270, 80)  # Punto central alrededor del cual gira el jefe

var velocidad_angular = 1.5  # Qué tan rápido gira el jefe en el patrón circular

func _ready():
	timer_disparo.wait_time = 1.2  # El jefe dispara cada 1.2 segundos
	timer_disparo.start()  # Arranca el temporizador de disparos
	centro_circular = Vector2(270, 80)  # Establece el centro del movimiento circular

func _process(delta):
	tiempo_fase += delta  # Suma el tiempo transcurrido desde el último frame
	if tiempo_fase >= duracion_patron:  # Si ya pasaron 5 segundos en el patrón actual
		tiempo_fase = 0.0  # Reinicia el contador
		patron_actual = (patron_actual + 1) % 2  # Cambia al otro patrón: 0 se vuelve 1, 1 se vuelve 0
	match patron_actual:  # Ejecuta el patrón que está activo
		0:
			_mover_zigzag(delta)  # Si es 0, se mueve en zigzag
		1:
			_mover_circular(delta)  # Si es 1, se mueve en círculo

func _mover_zigzag(delta):
	position.x += velocidad_zigzag * direccion_zigzag * delta  # Mueve el jefe horizontalmente
	if position.x > 460:  # Si llega al borde derecho de la pantalla
		direccion_zigzag = -1  # Cambia dirección hacia la izquierda
	elif position.x < 80:  # Si llega al borde izquierdo
		direccion_zigzag = 1  # Cambia dirección hacia la derecha

func _mover_circular(delta):
	angulo_circular += velocidad_angular * delta  # Aumenta el ángulo para hacer el giro
	position.x = centro_circular.x + cos(angulo_circular) * radio_circular  # Calcula la posición horizontal en el círculo
	position.y = centro_circular.y + sin(angulo_circular) * radio_circular * 0.4  # Calcula la posición vertical, más achatada

func explotar():
	vida -= 1  # Resta 1 punto de vida cuando el jugador golpea al jefe
	if vida <= 0:  # Si la vida llegó a cero o menos
		_morir()  # Ejecuta la muerte del jefe
	else:  # Si todavía tiene vida
		modulate = Color(10, 1, 1)  # Cambia el color a rojo para mostrar que recibió daño
		await get_tree().create_timer(0.1).timeout  # Espera una décima de segundo
		modulate = Color(1, 1, 1)  # Vuelve al color normal

func _morir():
	timer_disparo.stop()  # Detiene los disparos
	set_process(false)  # Detiene el movimiento
	$CollisionShape2D.set_deferred("disabled", true)  # Desactiva las colisiones para que el jugador lo atraviese
	$Sprite2D.visible = false  # Oculta el sprite normal del jefe
	sprite_explosion.visible = true  # Muestra la animación de explosión
	boss_derrotado.emit()  # Avisa que el jefe murió
	await get_tree().create_timer(1.5).timeout  # Espera segundo y medio
	queue_free()  # Elimina el jefe de la escena

func _on_timer_disparo_timeout():
	_disparar_todas_patas()  # Llama a la función que hace que todas las patas disparen
	timer_disparo.wait_time = randf_range(0.8, 1.5)  # El próximo disparo será entre 0.8 y 1.5 segundos
	timer_disparo.start()  # Reinicia el temporizador

func _disparar_todas_patas():
	for pata in patas:  # Recorre cada pata de la lista
		if pata == null:  # Si la pata no existe
			continue  # Salta a la siguiente
		var misil = MisilBoss.instantiate()  # Crea un nuevo misil
		misil.global_position = pata.global_position  # Coloca el misil en la posición de la pata
		var dir = Vector2(randf_range(-0.3, 0.3), 1).normalized()  # Dirección aleatoria con ligera variación horizontal
		get_parent().add_child(misil)  # Agrega el misil a la escena
		misil.iniciar(dir)  # Lanza el misil en la dirección calculada
*boss3.gd*

extends CharacterBody2D  # Permite controlar físicas y movimiento del jefe

signal boss3_derrotado  # Se activa cuando el tercer jefe muere

var MisilFuego = preload("res://scenes/misil_fuego.tscn")  # Carga la escena del misil de fuego

var ItemHielo = preload("res://scenes/item_hielo.tscn")  # Carga la escena del item de hielo

@onready var timer_disparo = $TimerDisparo  # Temporizador que controla cada cuánto dispara

@onready var timer_item = $TimerItem  # Temporizador que controla cada cuánto aparece un item de hielo

@onready var sprite_explosion = $SpriteEXPLOSION  # Imagen de explosión al morir

@onready var patas = [$Pata1, $Pata2, $Pata3, $Pata4, $Pata5, $Pata6, $Pata7, $Pata8, $Pata9, $Pata10]  # Lista de las diez patas del jefe

var vida = 500  # Puntos de vida, mucho más resistente que el jefe normal

var tiempo_movimiento = 0.0  # Acumula el tiempo para crear movimientos ondulantes

var congelado = false  # Si es verdadero, el jefe no se mueve ni dispara

var contar_hielo = 0  # Cuenta cuántos golpes de hielo ha recibido

var fase2_activa = false  # Si es verdadero, el jefe está en su segunda fase

var fase3_activa = false  # Si es verdadero, el jefe está en su tercera fase

func _ready():
	timer_disparo.wait_time = 1.5  # Al principio dispara cada segundo y medio
	timer_disparo.start()  # Arranca el temporizador de disparos
	timer_item.wait_time = 90.0  # Cada 90 segundos aparece un item de hielo
	timer_item.start()  # Arranca el temporizador de items

func _process(delta):
	if congelado:  # Si está congelado
		return  # No hace nada, no se mueve
	tiempo_movimiento += delta  # Suma el tiempo transcurrido
	
	var velocidad_base = 0.6 + ((500 - vida) / 100.0) * 0.2  # La velocidad aumenta cuando tiene menos vida
	
	if fase3_activa:  # En la tercera fase, el movimiento es muy errático
		position.x = 270 + sin(tiempo_movimiento * 2.1 * velocidad_base) * 160 + sin(tiempo_movimiento * 3.9 * velocidad_base) * 50 + sin(tiempo_movimiento * 5.7 * velocidad_base) * 20
		position.y = 80 + sin(tiempo_movimiento * 1.7 * velocidad_base) * 70 + sin(tiempo_movimiento * 3.2 * velocidad_base) * 30 + sin(tiempo_movimiento * 4.9 * velocidad_base) * 15
	elif fase2_activa:  # En la segunda fase, el movimiento es intermedio
		position.x = 270 + sin(tiempo_movimiento * 1.5 * velocidad_base) * 150 + sin(tiempo_movimiento * 2.7 * velocidad_base) * 45 + sin(tiempo_movimiento * 4.1 * velocidad_base) * 18
		position.y = 80 + sin(tiempo_movimiento * 1.1 * velocidad_base) * 60 + sin(tiempo_movimiento * 2.3 * velocidad_base) * 25 + sin(tiempo_movimiento * 3.5 * velocidad_base) * 12
	else:  # En la primera fase, el movimiento es suave
		position.x = 270 + sin(tiempo_movimiento * 1.0 * velocidad_base) * 140 + sin(tiempo_movimiento * 1.9 * velocidad_base) * 40 + sin(tiempo_movimiento * 3.1 * velocidad_base) * 15
		position.y = 80 + sin(tiempo_movimiento * 0.7 * velocidad_base) * 50 + sin(tiempo_movimiento * 1.5 * velocidad_base) * 22 + sin(tiempo_movimiento * 2.3 * velocidad_base) * 10

func recibir_hielo():
	contar_hielo += 1  # Aumenta el contador de golpes de hielo
	modulate = Color(0.3, 0.7, 1.0)  # Cambia a color azul claro
	if contar_hielo >= 5:  # Si recibió 5 golpes de hielo
		contar_hielo = 0  # Reinicia el contador
		_congelar()  # Congela al jefe

func _congelar():
	congelado = true  # Activa el estado congelado
	timer_disparo.stop()  # Detiene los disparos
	modulate = Color(0.0, 0.5, 1.0)  # Cambia a color azul más intenso
	await get_tree().create_timer(10.0).timeout  # Espera 10 segundos
	if is_instance_valid(self):  # Verifica que el jefe todavía existe
		congelado = false  # Desactiva el estado congelado
		modulate = Color(1, 1, 1)  # Vuelve al color normal
		timer_disparo.wait_time = 0.6  # Ahora dispara mucho más rápido
		timer_disparo.start()  # Reinicia los disparos

func explotar():
	if congelado:  # Si está congelado
		vida -= 1  # Recibe 1 de daño
	else:  # Si no está congelado
		vida -= 1  # También recibe 1 de daño
	if vida <= 250 and not fase2_activa:  # Si la vida baja de 250 y no está en fase 2
		fase2_activa = true  # Activa la fase 2
		timer_disparo.wait_time = 1.0  # Dispara más rápido
	if vida <= 100 and not fase3_activa:  # Si la vida baja de 100 y no está en fase 3
		fase3_activa = true  # Activa la fase 3
		timer_disparo.wait_time = 0.6  # Dispara aún más rápido
	if vida <= 0:  # Si la vida llegó a cero
		_morir()  # Ejecuta la muerte del jefe
	else:  # Si todavía tiene vida
		if not congelado:  # Si no está congelado
			modulate = Color(10, 1, 1)  # Cambia a color rojo para mostrar daño
			await get_tree().create_timer(0.1).timeout  # Espera una décima de segundo
			modulate = Color(1, 1, 1)  # Vuelve al color normal

func _morir():
	timer_disparo.stop()  # Detiene los disparos
	timer_item.stop()  # Detiene la aparición de items de hielo
	set_process(false)  # Detiene el movimiento
	$CollisionShape2D.set_deferred("disabled", true)  # Desactiva las colisiones
	$Sprite2D.visible = false  # Oculta el sprite normal
	sprite_explosion.visible = true  # Muestra la explosión
	boss3_derrotado.emit()  # Avisa que el jefe murió
	await get_tree().create_timer(1.5).timeout  # Espera segundo y medio
	queue_free()  # Elimina el jefe de la escena

func _on_timer_disparo_timeout():
	if congelado:  # Si está congelado
		return  # No dispara
	_disparar_todas_patas()  # Dispara desde todas las patas
	timer_disparo.start()  # Reinicia el temporizador

func _disparar_todas_patas():
	for i in range(patas.size()):  # Recorre cada pata por su número
		var pata = patas[i]
		if pata == null:  # Si la pata no existe
			continue  # Salta a la siguiente
		var misil = MisilFuego.instantiate()  # Crea un nuevo misil de fuego
		misil.global_position = pata.global_position  # Coloca el misil en la posición de la pata
		var angulo = -2.5 + (5.0 / (patas.size() - 1)) * i  # Calcula un ángulo diferente para cada pata
		var dir = Vector2(angulo, 1).normalized()  # Convierte el ángulo en dirección
		get_parent().add_child(misil)  # Agrega el misil a la escena
		misil.iniciar(dir)  # Lanza el misil en la dirección calculada

func _on_timer_item_timeout():
	var item = ItemHielo.instantiate()  # Crea un nuevo item de hielo
	item.global_position = Vector2(randf_range(60, 480), 0)  # Lo coloca arriba en una posición aleatoria
	get_parent().add_child(item)  # Agrega el item a la escena
	timer_item.wait_time = 90.0  # Reinicia el temporizador para 90 segundos
	timer_item.start()  # Arranca el temporizador nuevamente
	
*boss_2.gd*

extends CharacterBody2D  # Controla físicas y movimiento del segundo jefe

signal boss2_derrotado  # Avisa cuando este jefe muere

var MisilFuego = preload("res://scenes/misil_fuego.tscn")  # Carga el misil que dispara

@onready var timer_disparo = $TimerDisparo  # Controla cada cuanto disparan las patas

@onready var timer_rafaga = $TimerRafaga  # Controla las ráfagas del cañón central

@onready var sprite_explosion = $SpriteEXPLOSION  # Animación de explosión al morir

@onready var patas = [$Pata1, $Pata2, $Pata3, $Pata4]  # Las cuatro patas laterales

@onready var canon_central = $Pata5  # El cañón del medio que dispara en ráfaga

var vida = 150  # Puntos de vida del segundo jefe

var tiempo_movimiento = 0.0  # Acumula tiempo para el movimiento ondulante

var rafaga_contador = 0  # Cuenta cuántos misiles lleva la ráfaga actual

var en_rafaga = false  # Si es verdadero, está en medio de una ráfaga

var fase2_activa = false  # Si es verdadero, el jefe está en su segunda fase

func _ready():
	timer_disparo.wait_time = 1.2  # Al principio dispara cada 1.2 segundos
	timer_disparo.start()  # Arranca el timer de disparos de patas
	timer_rafaga.wait_time = 2.0  # Cada 2 segundos empieza una ráfaga
	timer_rafaga.start()  # Arranca el timer de ráfagas

func _process(delta):
	tiempo_movimiento += delta  # Suma el tiempo transcurrido
	if fase2_activa:  # En la fase dos el movimiento es más rápido y errático
		position.x = 270 + sin(tiempo_movimiento * 5.0) * 140 + sin(tiempo_movimiento * 7.3) * 40 + sin(tiempo_movimiento * 11.2) * 15
		position.y = 80 + sin(tiempo_movimiento * 3.2) * 45 + sin(tiempo_movimiento * 5.8) * 20 + sin(tiempo_movimiento * 9.1) * 10
	else:  # En la fase uno el movimiento es más suave
		position.x = 270 + sin(tiempo_movimiento * 3.0) * 140 + sin(tiempo_movimiento * 4.6) * 40 + sin(tiempo_movimiento * 8.2) * 15
		position.y = 80 + sin(tiempo_movimiento * 1.8) * 45 + sin(tiempo_movimiento * 3.4) * 20 + sin(tiempo_movimiento * 6.6) * 10

func explotar():
	vida -= 1  # Resta un punto de vida al recibir daño
	if vida <= 50 and not fase2_activa:  # Si la vida baja de 50 y no está en fase dos
		fase2_activa = true  # Activa la fase dos
		timer_disparo.wait_time = 0.4  # Ahora dispara mucho más rápido
		timer_disparo.start()  # Reinicia el timer con el nuevo tiempo
	if vida <= 0:  # Si la vida llegó a cero
		_morir()  # Ejecuta la muerte
	else:  # Si todavía vive
		modulate = Color(10, 1, 1)  # Cambia a color rojo por el golpe
		await get_tree().create_timer(0.1).timeout  # Espera una décima de segundo
		modulate = Color(1, 1, 1)  # Vuelve al color normal

func _morir():
	timer_disparo.stop()  # Detiene los disparos de las patas
	timer_rafaga.stop()  # Detiene las ráfagas del cañón central
	set_process(false)  # Detiene el movimiento
	$CollisionShape2D.set_deferred("disabled", true)  # Desactiva las colisiones
	$Sprite2D.visible = false  # Oculta el sprite normal
	sprite_explosion.visible = true  # Muestra la explosión
	boss2_derrotado.emit()  # Avisa que el jefe murió
	await get_tree().create_timer(1.5).timeout  # Espera segundo y medio
	queue_free()  # Elimina el jefe

func _on_timer_disparo_timeout():
	_disparar_todas_patas()  # Dispara desde las cuatro patas laterales
	if fase2_activa:  # En fase dos
		timer_disparo.wait_time = randf_range(0.4, 0.8)  # Espera entre 0.4 y 0.8 segundos
	else:  # En fase uno
		timer_disparo.wait_time = randf_range(0.8, 1.5)  # Espera entre 0.8 y 1.5 segundos
	timer_disparo.start()  # Reinicia el timer

func _on_timer_rafaga_timeout():
	if en_rafaga:  # Si ya está en medio de una ráfaga
		var misil = MisilFuego.instantiate()  # Crea un nuevo misil
		misil.global_position = canon_central.global_position  # Lo coloca en el cañón central
		get_parent().add_child(misil)  # Agrega el misil a la escena
		misil.iniciar(Vector2(0, 1))  # Lo lanza hacia abajo
		rafaga_contador += 1  # Aumenta el contador de la ráfaga
		var limite_rafaga = 8 if fase2_activa else 5  # En fase dos dispara 8 balas, en fase uno 5
		var pausa_rafaga = 0.05 if fase2_activa else 0.15  # En fase dos dispara más rápido entre balas
		var pausa_entre = randf_range(0.8, 1.5) if fase2_activa else 2.0  # Pausa antes de la siguiente ráfaga
		if rafaga_contador >= limite_rafaga:  # Si ya terminó la ráfaga
			en_rafaga = false  # Sale del estado de ráfaga
			rafaga_contador = 0  # Reinicia el contador
			timer_rafaga.wait_time = pausa_entre  # Espera antes de la próxima ráfaga
		else:  # Si todavía no termina la ráfaga
			timer_rafaga.wait_time = pausa_rafaga  # Espera muy poco para el siguiente misil
	else:  # Si no está en ráfaga, la empieza
		en_rafaga = true  # Activa el estado de ráfaga
		rafaga_contador = 0  # Reinicia el contador
		if fase2_activa:  # En fase dos
			timer_rafaga.wait_time = 0.05  # Disparo ultrarrápido
		else:  # En fase uno
			timer_rafaga.wait_time = 0.15  # Disparo rápido
	timer_rafaga.start()  # Reinicia el timer

func _disparar_todas_patas():
	for pata in patas:  # Recorre cada pata lateral
		if pata == null:  # Si la pata no existe
			continue  # Salta a la siguiente
		var misil = MisilFuego.instantiate()  # Crea un nuevo misil
		misil.global_position = pata.global_position  # Lo coloca en la posición de la pata
		var dir = Vector2(randf_range(-0.3, 0.3), 1).normalized()  # Dirección con ligera variación horizontal
		get_parent().add_child(misil)  # Agrega el misil a la escena
		misil.iniciar(dir)  # Lanza el misil
		
*enemigo.gd*

extends CharacterBody2D  # Controla el movimiento del enemigo básico

signal enemigo_eliminado(referencia_enemigo)  # Avisa cuando este enemigo muere

var Misil = preload("res://scenes/misil_enemigo.tscn")  # Carga el misil que dispara

@onready var timer_movimiento = $Timer_movimiento  # Controla el movimiento lateral

@onready var sprite_explosion = $SpriteEXPLOSION  # Animación de explosión al morir

@onready var spawn_izquierdo = $SpawnPoint  # Punto desde donde sale el misil izquierdo

@onready var spawn_derecho = $SpawnPoint2  # Punto desde donde sale el misil derecho

var origen = 0  # Posición original del enemigo para moverse dentro de un rango

var rango = 40  # Qué tan lejos se puede mover a cada lado

var paso = 7  # Cuántos píxeles se mueve cada vez

var direccion = 1  # 1 es derecha, -1 es izquierda

var vida = 2  # Puntos de vida, necesita dos golpes para morir

var rayo_izq: RayCast2D  # Rayo que detecta si hay otro enemigo a la izquierda

func _ready():
	timer_movimiento.start()  # Arranca el movimiento
	origen = self.position.x  # Guarda la posición original
	rayo_izq = RayCast2D.new()  # Crea un nuevo rayo
	add_child(rayo_izq)  # Agrega el rayo como hijo
	rayo_izq.target_position = Vector2(-45, 0)  # El rayo apunta 45 píxeles a la izquierda
	rayo_izq.enabled = true  # Activa el rayo
	rayo_izq.collide_with_areas = true  # El rayo detecta áreas
	rayo_izq.collide_with_bodies = true  # El rayo detecta cuerpos

func _on_timer_movimiento_timeout() -> void:
	self.position.x += paso * direccion  # Mueve el enemigo hacia la dirección actual
	if self.position.x >= rango + origen or self.position.x < origen - rango:  # Si llega al límite
		direccion *= -1  # Cambia de dirección

func explotar():
	vida -= 1  # Resta un punto de vida
	if vida <= 0:  # Si la vida llegó a cero
		timer_movimiento.stop()  # Detiene el movimiento
		$CollisionShape2D.set_deferred("disabled", true)  # Desactiva las colisiones
		$SpriteENEMIGO.visible = false  # Oculta el primer sprite
		$SpriteENEMIGO2.visible = false  # Oculta el segundo sprite
		$SpriteENEMIGO3.visible = false  # Oculta el tercer sprite
		sprite_explosion.visible = true  # Muestra la explosión
		enemigo_eliminado.emit(self)  # Avisa que murió
		await get_tree().create_timer(0.5).timeout  # Espera medio segundo
		queue_free()  # Elimina el enemigo
	else:  # Si todavía tiene vida
		modulate = Color(10, 1, 1)  # Cambia a color rojo por el golpe
		await get_tree().create_timer(0.1).timeout  # Espera una décima de segundo
		modulate = Color(1, 1, 1)  # Vuelve al color normal

func _on_timer_disparar_timeout() -> void:
	pass  # Este timer no se usa en este enemigo

func activar_sprite_por_fila(num_fila: int):
	# Muestra el sprite correcto según la fila en la que está el enemigo
	$SpriteENEMIGO.visible = false
	$SpriteENEMIGO2.visible = false
	$SpriteENEMIGO3.visible = false
	if num_fila == 2 or num_fila == 3:  # Filas 2 y 3 usan el primer sprite
		$SpriteENEMIGO.visible = true
	elif num_fila == 1:  # Fila 1 usa el segundo sprite
		$SpriteENEMIGO2.visible = true
	elif num_fila == 0:  # Fila 0 usa el tercer sprite
		$SpriteENEMIGO3.visible = true

func disparar():
	# Dispara dos misiles, uno por cada spawn
	var misil_izq = Misil.instantiate()  # Crea misil izquierdo
	misil_izq.global_position = spawn_izquierdo.global_position  # Lo coloca en el spawn izquierdo
	get_parent().add_child(misil_izq)  # Agrega el misil a la escena
	var misil_der = Misil.instantiate()  # Crea misil derecho
	misil_der.global_position = spawn_derecho.global_position  # Lo coloca en el spawn derecho
	get_parent().add_child(misil_der)  # Agrega el misil a la escena

func tiene_obstaculo_izq() -> bool:
	# Detecta si hay otro enemigo a la izquierda
	if rayo_izq == null:  # Si no hay rayo
		return false  # No hay obstáculo
	if rayo_izq.is_colliding():  # Si el rayo chocó con algo
		var colisionador = rayo_izq.get_collider()  # Obtiene lo que chocó
		if colisionador != self:  # Si no es él mismo
			return true  # Hay obstáculo
	return false  # No hay obstáculo
	
*enemigo_nivel3.gd*

extends CharacterBody2D  # Controla el enemigo avanzado del nivel 3

signal enemigo_eliminado(referencia)  # Avisa cuando este enemigo muere

var MisilEnemigo = preload("res://scenes/misil_enemigo.tscn")  # Carga el misil que dispara

@onready var sprite_nave1 = $SpriteNAVE1  # Sprite para filas 0 y 1
@onready var sprite_nave2 = $SpriteNAVE2  # Sprite para fila 2
@onready var sprite_nave3 = $SpriteNAVE3  # Sprite para fila 3
@onready var sprite_explosion = $SpriteEXPLOSION  # Animación de explosión
@onready var timer_disparo = $TimerDisparo  # Controla cada cuanto dispara
@onready var spawn1 = $SpawnMisil1  # Punto de disparo izquierdo
@onready var spawn2 = $SpawnMisil2  # Punto de disparo derecho

var vida = 3  # Puntos de vida, resiste tres golpes
var tipo_movimiento = 0  # 0 es movimiento suave, 1 es agresivo, 2 es aleatorio
var posicion_formacion = Vector2.ZERO  # Guarda la posición original en la formación
var en_formacion = true  # Si es verdadero, está quieto en formación
var tiempo = 0.0  # Acumula tiempo
var atacando = false  # Si es verdadero, está bajando a atacar
var regresando = false  # Si es verdadero, está volviendo a la formación

var progreso_curva = 0.0  # Qué tanto ha avanzado en la curva de ataque
var velocidad_curva = 0.8  # Qué tan rápido se mueve por la curva
var puntos_curva = []  # Lista de puntos por donde pasa el enemigo en su ataque

func activar_sprite_por_fila(num_fila: int):
	# Muestra el sprite correcto según la fila y define el tipo de movimiento
	sprite_nave1.visible = false
	sprite_nave2.visible = false
	sprite_nave3.visible = false
	if num_fila == 0 or num_fila == 1:  # Filas 0 y 1
		sprite_nave1.visible = true  # Usan nave1
		tipo_movimiento = 0  # Movimiento suave
	elif num_fila == 2:  # Fila 2
		sprite_nave2.visible = true  # Usa nave2
		tipo_movimiento = 1  # Movimiento agresivo
	elif num_fila == 3:  # Fila 3
		sprite_nave3.visible = true  # Usa nave3
		tipo_movimiento = 2  # Movimiento aleatorio

func guardar_posicion_formacion():
	posicion_formacion = global_position  # Guarda la posición actual como punto de regreso

func iniciar_ataque():
	if atacando or regresando:  # Si ya está atacando o regresando
		return  # No hace nada
	atacando = true  # Activa el estado de ataque
	en_formacion = false  # Ya no está en formación
	progreso_curva = 0.0  # Reinicia el progreso de la curva
	_generar_curva()  # Crea la curva de ataque según su tipo
	timer_disparo.wait_time = randf_range(0.5, 1.0)  # Espera entre medio y un segundo para disparar
	timer_disparo.start()  # Arranca el timer de disparos

func _generar_curva():
	var inicio = global_position  # Posición actual
	var destino = Vector2(randf_range(60, 480), 320)  # Punto de ataque hacia abajo de la pantalla
	match tipo_movimiento:
		0:  # Movimiento suave con curva en S
			puntos_curva = [
				inicio,
				Vector2(inicio.x + randf_range(-80, 80), inicio.y + 80),
				Vector2(destino.x + randf_range(-60, 60), destino.y - 80),
				destino
			]
		1:  # Movimiento agresivo que hace un loop antes de bajar
			puntos_curva = [
				inicio,
				Vector2(inicio.x + randf_range(-120, 120), inicio.y - 60),
				Vector2(inicio.x + randf_range(-100, 100), inicio.y + 40),
				Vector2(destino.x + randf_range(-80, 80), destino.y - 60),
				destino
			]
		2:  # Movimiento aleatorio e impredecible
			puntos_curva = [
				inicio,
				Vector2(randf_range(40, 500), randf_range(50, 200)),
				Vector2(randf_range(40, 500), randf_range(150, 280)),
				destino
			]

func _process(delta):
	tiempo += delta  # Suma el tiempo
	if atacando:  # Si está atacando
		progreso_curva += delta * velocidad_curva  # Avanza en la curva
		if progreso_curva >= 1.0:  # Si llegó al final
			progreso_curva = 1.0  # Lo fija en el máximo
			atacando = false  # Termina el ataque
			regresando = true  # Empieza el regreso
			progreso_curva = 0.0  # Reinicia el progreso
			_generar_curva_regreso()  # Crea la curva para volver
		else:  # Si todavía no llegó
			global_position = _bezier(puntos_curva, progreso_curva)  # Mueve el enemigo por la curva
	elif regresando:  # Si está regresando
		progreso_curva += delta * velocidad_curva  # Avanza en la curva de regreso
		if progreso_curva >= 1.0:  # Si llegó a la formación
			global_position = posicion_formacion  # Lo coloca exactamente en su posición original
			regresando = false  # Termina el regreso
			en_formacion = true  # Vuelve a estar en formación
			timer_disparo.stop()  # Deja de disparar
		else:  # Si todavía no llegó
			global_position = _bezier(puntos_curva, progreso_curva)  # Mueve por la curva de regreso

func _generar_curva_regreso():
	var inicio = global_position  # Posición actual donde terminó el ataque
	# Crea una curva simple para volver a la formación
	puntos_curva = [
		inicio,
		Vector2(inicio.x + randf_range(-60, 60), inicio.y - 80),
		Vector2(posicion_formacion.x + randf_range(-40, 40), posicion_formacion.y + 80),
		posicion_formacion
	]

func _bezier(puntos: Array, t: float) -> Vector2:
	# Calcula un punto en una curva de Bezier según el progreso t
	var n = puntos.size() - 1
	var resultado = Vector2.ZERO
	for i in range(puntos.size()):
		var coef = _binomial(n, i) * pow(1 - t, n - i) * pow(t, i)
		resultado += puntos[i] * coef
	return resultado

func _binomial(n: int, k: int) -> float:
	# Calcula el coeficiente binomial para la curva de Bezier
	if k == 0 or k == n:
		return 1.0
	var resultado = 1.0
	for i in range(k):
		resultado *= float(n - i) / float(i + 1)
	return resultado

func explotar():
	vida -= 1  # Resta un punto de vida
	if vida <= 0:  # Si la vida llegó a cero
		timer_disparo.stop()  # Detiene los disparos
		enemigo_eliminado.emit(self)  # Avisa que murió
		$CollisionShape2D.set_deferred("disabled", true)  # Desactiva colisiones
		sprite_nave1.visible = false  # Oculta nave1
		sprite_nave2.visible = false  # Oculta nave2
		sprite_nave3.visible = false  # Oculta nave3
		sprite_explosion.visible = true  # Muestra explosión
		await get_tree().create_timer(0.5).timeout  # Espera medio segundo
		queue_free()  # Elimina el enemigo
	else:  # Si todavía tiene vida
		modulate = Color(10, 1, 1)  # Cambia a color rojo
		await get_tree().create_timer(0.1).timeout  # Espera una décima de segundo
		modulate = Color(1, 1, 1)  # Vuelve al color normal

func _on_timer_disparo_timeout():
	if atacando:  # Solo dispara mientras está atacando
		_disparar()  # Dispara dos misiles
		timer_disparo.wait_time = randf_range(0.5, 1.2)  # Espera entre medio y 1.2 segundos
		timer_disparo.start()  # Reinicia el timer

func _disparar():
	# Dispara dos misiles desde los dos spawns
	var misil1 = MisilEnemigo.instantiate()
	misil1.global_position = spawn1.global_position
	get_parent().add_child(misil1)
	var misil2 = MisilEnemigo.instantiate()
	misil2.global_position = spawn2.global_position
	get_parent().add_child(misil2)
	
*game_state.gd*

extends Node  # Nodo para almacenar variables globales del juego

var solo_boss = false  # Si es verdadero, el juego carga directamente el jefe sin oleadas

*grupo_enemigos.gd*

extends Node  # Controla toda la formación de enemigos

var Enemigo = preload("res://scenes/enemigo.tscn")  # Carga la escena del enemigo básico

@onready var timer_disparo = $TimerDISPARAR  # Controla cada cuanto dispara un enemigo

@onready var timer_descender = $TimerDESCENDER  # Controla cada cuanto bajan todos

var Boss = preload("res://scenes/boss.tscn")  # Carga la escena del jefe

var lista_enemigos = []  # Matriz bidimensional que guarda todos los enemigos

var direccion_vertical = 1  # 1 es bajar, -1 es subir

var limite_inferior = 300  # Hasta dónde pueden bajar los enemigos

var limite_superior = 30  # Hasta dónde pueden subir los enemigos

var oleada_actual = 0  # Qué oleada va actualmente, empieza en 0

# Tiempos entre descensos según la oleada
var tiempos_descenso = [15.0, 7.0, 5.0, 3.0]

# Tiempo mínimo entre disparos según la oleada
var tiempos_disparo_min = [1.5, 0.8, 0.4, 0.2]

# Tiempo máximo entre disparos según la oleada
var tiempos_disparo_max = [3.0, 1.5, 0.8, 0.4]

var enemigos_vivos = 0  # Cuántos enemigos quedan vivos

var solo_boss = false  # Si es verdadero, aparece solo el jefe

func _ready():
	if GameState.solo_boss:  # Si la variable global dice que solo debe aparecer el jefe
		GameState.solo_boss = false  # La reinicia
		await get_tree().create_timer(1.0).timeout  # Espera un segundo
		_invocar_boss()  # Llama al jefe directamente
	else:  # Si no
		iniciar_oleada()  # Empieza la oleada normal

func iniciar_oleada():
	lista_enemigos.clear()  # Limpia la lista de enemigos
	direccion_vertical = 1  # Los enemigos empiezan bajando

	# Configura el tiempo de descenso según la oleada actual
	var tiempo_desc = tiempos_descenso[min(oleada_actual, tiempos_descenso.size() - 1)]
	timer_descender.wait_time = tiempo_desc
	timer_descender.start()

	# Configura el tiempo de disparo según la oleada actual
	var idx = min(oleada_actual, tiempos_disparo_min.size() - 1)
	timer_disparo.wait_time = tiempos_disparo_max[idx]
	timer_disparo.start()

	# Muestra en consola los datos de la oleada
	print("Oleada %d — descenso: %.1fs  disparo: %.1f-%.1fs" % [
		oleada_actual + 1, tiempo_desc,
		tiempos_disparo_min[idx], tiempos_disparo_max[idx]
	])

	enemigos_vivos = 0  # Reinicia el contador
	# Crea 4 filas de enemigos
	for j in range(4):
		lista_enemigos.append([])  # Agrega una nueva fila
		# Crea 9 columnas por fila
		for i in range(9):
			var enemigo = Enemigo.instantiate()  # Crea un nuevo enemigo
			# Lo coloca en posición: 80 de margen izquierdo + 50 por columna, 30 de margen arriba + 40 por fila
			enemigo.global_position = Vector2(80 + 50 * i, 30 + 40 * j)
			self.add_child(enemigo)  # Agrega el enemigo como hijo
			enemigo.activar_sprite_por_fila(j)  # Muestra el sprite correcto según la fila
			enemigo.enemigo_eliminado.connect(_on_enemigo_eliminado)  # Conecta la señal de muerte
			lista_enemigos[j].append(enemigo)  # Guarda el enemigo en la matriz
			enemigos_vivos += 1  # Aumenta el contador

func _on_enemigo_eliminado(nave_muerta):
	# Busca la nave muerta en la matriz y la elimina
	for fila in range(len(lista_enemigos)):
		for col in range(len(lista_enemigos[fila])):
			if lista_enemigos[fila][col] == nave_muerta:
				lista_enemigos[fila][col] = null  # Vacía esa posición
				break
				
	enemigos_vivos -= 1  # Reduce el contador de vivos
	
	print("Enemigos restantes: %d" % enemigos_vivos)
	revisar_y_cerrar_columnas_vacias()  # Mueve los enemigos para cerrar huecos
	
	if enemigos_vivos <= 0:  # Si no quedan enemigos
		oleada_actual += 1  # Pasa a la siguiente oleada
		timer_descender.stop()  # Detiene el descenso
		timer_disparo.stop()  # Detiene los disparos
		var jugador = get_tree().get_first_node_in_group("jugador")  # Busca al jugador
		if jugador and is_instance_valid(jugador):
			jugador.reiniciar_vida()  # Recupera la vida del jugador
		if oleada_actual >= 4:  # Si ya pasaron 4 oleadas
			await get_tree().create_timer(3.0).timeout  # Espera 3 segundos
			_invocar_boss()  # Llama al jefe
		else:  # Si no
			await get_tree().create_timer(2.0).timeout  # Espera 2 segundos
			iniciar_oleada()  # Empieza la siguiente oleada

func _invocar_boss():
	var boss = Boss.instantiate()  # Crea el jefe
	boss.global_position = Vector2(270, 60)  # Lo coloca arriba en el centro
	boss.boss_derrotado.connect(_on_boss_derrotado)  # Conecta la señal de muerte
	get_parent().add_child(boss)  # Agrega el jefe a la escena

func _on_boss_derrotado():
	await get_tree().create_timer(2.0).timeout  # Espera 2 segundos
	get_tree().change_scene_to_file("res://scenes/main2.tscn")  # Cambia al siguiente nivel

func revisar_y_cerrar_columnas_vacias():
	# Revisa de derecha a izquierda si hay columnas sin enemigos
	for col in range(8, -1, -1):
		var columna_vacia = true
		for fila in range(len(lista_enemigos)):
			if lista_enemigos[fila][col] != null and is_instance_valid(lista_enemigos[fila][col]):
				columna_vacia = false
				break
		if columna_vacia:  # Si la columna está vacía
			print("¡Columna vacía detectada! Moviendo escuadrón...")
			# Mueve todos los enemigos de las columnas derechas hacia la izquierda
			for fila in range(len(lista_enemigos)):
				for c_der in range(8, col, -1):
					var enemigo_a_mover = lista_enemigos[fila][c_der]
					if enemigo_a_mover != null and is_instance_valid(enemigo_a_mover):
						if enemigo_a_mover.tiene_obstaculo_izq():
							continue
						enemigo_a_mover.position.x -= 50  # Mueve el enemigo 50 píxeles a la izquierda
			# Elimina la columna vacía de la matriz y agrega una vacía al final
			for fila in range(len(lista_enemigos)):
				lista_enemigos[fila].remove_at(col)
				lista_enemigos[fila].append(null)

func _on_timer_descender_timeout() -> void:
	# Encuentra al enemigo más bajo y al más alto
	var y_mas_bajo = -INF
	var y_mas_alto = INF
	for fila in lista_enemigos:
		for a in fila:
			if is_instance_valid(a):
				if a.position.y > y_mas_bajo:
					y_mas_bajo = a.position.y
				if a.position.y < y_mas_alto:
					y_mas_alto = a.position.y
	# Si llegaron al límite inferior, cambia dirección hacia arriba
	if y_mas_bajo >= limite_inferior:
		direccion_vertical = -1
	# Si llegaron al límite superior, cambia dirección hacia abajo
	elif y_mas_alto <= limite_superior:
		direccion_vertical = 1
	# Mueve todos los enemigos hacia arriba o abajo
	for fila in lista_enemigos:
		for a in fila:
			if is_instance_valid(a):
				a.position.y += (21 * direccion_vertical)

func _on_timer_disparar_timeout() -> void:
	# Crea una lista con todos los enemigos que están vivos
	var lista_enemigos_vivos = []
	for fila in lista_enemigos:
		for a in fila:
			if is_instance_valid(a) and !a.is_queued_for_deletion():
				lista_enemigos_vivos.append(a)
	# Si hay al menos un enemigo vivo
	if lista_enemigos_vivos:
		# Elige un enemigo al azar
		var indice = int(floor(randf_range)
		
*grupo_nivel2.gd*

extends Node  # Controla la oleada de enemigos del segundo nivel

var NaveRosa = preload("res://scenes/nave_rosa.tscn")  # Carga la nave rosa que se mueve lento
var NaveBlanca = preload("res://scenes/nave_blanca.tscn")  # Carga la nave blanca que se mueve rápido
var Boss2 = preload("res://scenes/boss2.tscn")  # Carga el segundo jefe

@onready var timer_spawn = $TimerSpawn  # Controla cada cuanto aparecen naves
@onready var timer_nivel = $TimerNivel  # Controla cuánto dura el nivel antes del jefe

var tiempo_transcurrido = 0.0  # Acumula el tiempo que lleva el nivel activo
var duracion_nivel = 300.0  # El nivel dura 300 segundos o 5 minutos
var boss_invocado = false  # Evita que se invoque al jefe más de una vez

var intervalo_spawn = 1.2  # Al principio aparecen naves cada 1.2 segundos
var velocidad_rosas = 60.0  # Las naves rosas bajan lentamente
var velocidad_blancas = 350.0  # Las naves blancas bajan muy rápido
var cantidad_grupo = 2  # Cuántas naves rosas aparecen por grupo

var solo_boss = false  # Si es verdadero, solo aparece el jefe

func _ready():
	if GameState.solo_boss:  # Si la variable global dice que solo debe aparecer el jefe
		GameState.solo_boss = false  # La reinicia
		await get_tree().create_timer(1.0).timeout  # Espera un segundo
		_invocar_boss()  # Llama al jefe directamente
	else:  # Si no
		timer_spawn.wait_time = intervalo_spawn  # Configura el tiempo de spawn
		timer_spawn.start()  # Arranca el timer de spawn
		timer_nivel.wait_time = duracion_nivel  # Configura la duración del nivel
		timer_nivel.start()  # Arranca el timer del nivel

func _process(delta):
	tiempo_transcurrido += delta  # Acumula el tiempo
	var nivel_dificultad = int(tiempo_transcurrido / 30.0)  # Cada 30 segundos sube la dificultad
	# Ajusta el intervalo de spawn, más rápido con la dificultad
	intervalo_spawn = max(0.3, 1.2 - nivel_dificultad * 0.15)
	# Aumenta la velocidad de las naves rosas con la dificultad
	velocidad_rosas = min(180.0, 60.0 + nivel_dificultad * 15.0)
	# Aumenta la velocidad de las naves blancas con la dificultad
	velocidad_blancas = min(500.0, 350.0 + nivel_dificultad * 20.0)
	# Aumenta la cantidad de naves por grupo con la dificultad
	cantidad_grupo = min(5, 2 + int(nivel_dificultad / 2))

func _on_timer_spawn_timeout():
	# Crea las naves rosas según la cantidad del grupo
	for i in range(cantidad_grupo):
		var rosa = NaveRosa.instantiate()  # Crea una nave rosa
		var x = randf_range(100, 440)  # Posición horizontal aleatoria
		if randf() > 0.6:  # El 40 por ciento de las veces
			x = randf_range(200, 340)  # Aparece más centrada
		rosa.global_position = Vector2(x, randf_range(-80, -10))  # Aparece arriba fuera de pantalla
		rosa.velocidad_y = velocidad_rosas  # Asigna la velocidad según dificultad
		get_parent().add_child(rosa)  # Agrega la nave a la escena
		
	# Decide cuántas naves blancas aparecen
	var num_blancas = 1  # Por defecto aparece una
	if randf() > 0.5:  # El 50 por ciento de las veces
		num_blancas = 2  # Aparecen dos
	if randf() > 0.8:  # El 20 por ciento de las veces
		num_blancas = 3  # Aparecen tres
	# Crea las naves blancas
	for i in range(num_blancas):
		var blanca = NaveBlanca.instantiate()  # Crea una nave blanca
		blanca.global_position = Vector2(randf_range(40, 500), randf_range(-80, -10))  # Aparece arriba
		blanca.velocidad_y = velocidad_blancas  # Asigna velocidad rápida
		get_parent().add_child(blanca)  # Agrega la nave a la escena

	timer_spawn.wait_time = intervalo_spawn  # Actualiza el tiempo de spawn
	timer_spawn.start()  # Reinicia el timer

func _on_timer_nivel_timeout():
	timer_spawn.stop()  # Detiene la aparición de naves
	_limpiar_pantalla()  # Elimina todas las naves que quedan
	await get_tree().create_timer(3.0).timeout  # Espera 3 segundos
	_invocar_boss()  # Llama al jefe

func _limpiar_pantalla():
	# Busca todas las naves que están en el grupo enemigos
	for nave in get_tree().get_nodes_in_group("enemigos"):
		if is_instance_valid(nave) and not nave.is_in_group("boss"):  # Si no es el jefe
			nave.queue_free()  # Las elimina

func _invocar_boss():
	if boss_invocado:  # Si ya se invocó al jefe
		return  # No hace nada
	boss_invocado = true  # Marca que ya se invocó
	timer_spawn.stop()  # Detiene el spawn
	_limpiar_pantalla()  # Limpia todas las naves
	await get_tree().create_timer(1.0).timeout  # Espera un segundo
	var boss = Boss2.instantiate()  # Crea el segundo jefe
	boss.global_position = Vector2(270, 60)  # Lo coloca arriba en el centro
	boss.boss2_derrotado.connect(_on_boss2_derrotado)  # Conecta la señal de muerte
	get_parent().add_child(boss)  # Agrega el jefe a la escena
	
func _on_boss2_derrotado():
	await get_tree().create_timer(2.0).timeout  # Espera 2 segundos
	get_tree().change_scene_to_file("res://scenes/main3.tscn")  # Cambia al tercer nivel
	
*grupo_nivel3.gd*

extends Node  # Controla la formación de enemigos del tercer nivel

var Enemigo3 = preload("res://scenes/enemigo_2.tscn")  # Carga el enemigo avanzado del nivel 3

var lista_enemigos = []  # Matriz que guarda todos los enemigos
var enemigos_vivos = 0  # Cuántos enemigos quedan vivos
var oleada_actual = 0  # Qué oleada va actualmente

@onready var timer_ataque = $TimerAtaque  # Controla cada cuanto atacan los enemigos
@onready var timer_movimiento = $TimerMovimiento  # Controla el movimiento lateral de la formación

var naves_por_ataque = [1, 2, 3]  # En oleada 0 ataca 1 nave, en oleada 1 atacan 2, en oleada 2 atacan 3
var intervalo_ataque = [3.0, 2.0, 1.2]  # Tiempo entre ataques según la oleada

var direccion_horizontal = 1  # 1 es derecha, -1 es izquierda
var limite_derecho = 480  # Límite derecho de la pantalla
var limite_izquierdo = 80  # Límite izquierdo de la pantalla
var paso_horizontal = 1  # Cuánto se mueve la formación cada vez

var Boss3 = preload("res://scenes/boss_3.tscn")  # Carga el tercer jefe
var boss_invocado = false  # Evita invocar al jefe más de una vez

var solo_boss = false  # Si es verdadero, solo aparece el jefe

func _ready():
	if GameState.solo_boss:  # Si la variable global dice que solo debe aparecer el jefe
		GameState.solo_boss = false  # La reinicia
		await get_tree().create_timer(1.0).timeout  # Espera un segundo
		_invocar_boss()  # Llama al jefe directamente
	else:  # Si no
		iniciar_oleada()  # Empieza la primera oleada
		timer_movimiento.wait_time = 0.01  # El movimiento se actualiza cada centésima de segundo
		timer_movimiento.start()  # Arranca el movimiento
	
func iniciar_oleada():
	lista_enemigos.clear()  # Limpia la lista de enemigos
	enemigos_vivos = 0  # Reinicia el contador
	var idx = min(oleada_actual, intervalo_ataque.size() - 1)  # Índice según la oleada
	timer_ataque.wait_time = intervalo_ataque[idx]  # Configura el tiempo de ataque
	timer_ataque.start()  # Arranca el timer de ataque
	print("Oleada %d" % (oleada_actual + 1))  # Muestra en consola la oleada actual
	# Crea 4 filas de enemigos
	for j in range(4):
		lista_enemigos.append([])  # Agrega una nueva fila
		# Crea 9 columnas por fila
		for i in range(9):
			var enemigo = Enemigo3.instantiate()  # Crea un nuevo enemigo avanzado
			enemigo.global_position = Vector2(80 + 50 * i, 30 + 40 * j)  # Posición en formación
			self.add_child(enemigo)  # Agrega el enemigo como hijo
			enemigo.activar_sprite_por_fila(j)  # Muestra el sprite según la fila
			enemigo.guardar_posicion_formacion()  # Guarda su posición para poder regresar después de atacar
			enemigo.enemigo_eliminado.connect(_on_enemigo_eliminado)  # Conecta señal de muerte
			lista_enemigos[j].append(enemigo)  # Guarda el enemigo en la matriz
			enemigos_vivos += 1  # Aumenta el contador

func _on_timer_ataque_timeout():
	var idx = min(oleada_actual, naves_por_ataque.size() - 1)  # Cuántas naves atacan esta oleada
	var cantidad = naves_por_ataque[idx]
	var disponibles = []  # Lista de enemigos que están en formación y pueden atacar
	# Recorre todos los enemigos buscando los que están en formación
	for fila in lista_enemigos:
		for enemigo in fila:
			if enemigo != null and is_instance_valid(enemigo) and enemigo.en_formacion:
				disponibles.append(enemigo)
	disponibles.shuffle()  # Mezcla la lista para que sea aleatorio quién ataca
	var a_atacar = min(cantidad, disponibles.size())  # Ataca la cantidad indicada o menos si no hay suficientes
	for i in range(a_atacar):
		disponibles[i].iniciar_ataque()  # Ordena al enemigo que empiece su ataque
	timer_ataque.wait_time = intervalo_ataque[min(oleada_actual, intervalo_ataque.size() - 1)]  # Configura próximo ataque
	timer_ataque.start()  # Reinicia el timer

func _on_enemigo_eliminado(nave_muerta):
	# Busca la nave muerta en la matriz y la elimina
	for fila in range(len(lista_enemigos)):
		for col in range(len(lista_enemigos[fila])):
			if lista_enemigos[fila][col] == nave_muerta:
				lista_enemigos[fila][col] = null  # Vacía esa posición
				break
	enemigos_vivos -= 1  # Reduce el contador de vivos
	print("Enemigos restantes: %d" % enemigos_vivos)
	if enemigos_vivos <= 0:  # Si no quedan enemigos
		oleada_actual += 1  # Pasa a la siguiente oleada
		timer_ataque.stop()  # Detiene los ataques
		timer_movimiento.stop()  # Detiene el movimiento
		var jugador = get_tree().get_first_node_in_group("jugador")  # Busca al jugador
		if jugador and is_instance_valid(jugador):
			jugador.reiniciar_vida()  # Recupera la vida del jugador
		if oleada_actual >= 3:  # Si ya pasaron 3 oleadas
			await get_tree().create_timer(3.0).timeout  # Espera 3 segundos
			_invocar_boss()  # Llama al jefe
		else:  # Si no
			await get_tree().create_timer(2.0).timeout  # Espera 2 segundos
			iniciar_oleada()  # Empieza la siguiente oleada

func _invocar_boss():
	if boss_invocado:  # Si ya se invocó al jefe
		return  # No hace nada
	boss_invocado = true  # Marca que ya se invocó
	var boss = Boss3.instantiate()  # Crea el tercer jefe
	boss.global_position = Vector2(270, 60)  # Lo coloca arriba en el centro
	boss.boss3_derrotado.connect(_on_boss3_derrotado)  # Conecta la señal de muerte
	get_parent().add_child(boss)  # Agrega el jefe a la escena

func _on_boss3_derrotado():
	await get_tree().create_timer(2.0).timeout  # Espera 2 segundos
	print("¡Juego completado!")  # Muestra mensaje de victoria

var rango_movimiento = 60  # Cuántos píxeles se mueve la formación a cada lado

func _on_timer_movimiento_timeout():
	# Busca el enemigo más a la derecha y el más a la izquierda en la formación
	var x_mas_derecha = -INF
	var x_mas_izquierda = INF
	for fila in lista_enemigos:
		for enemigo in fila:
			if enemigo != null and is_instance_valid(enemigo) and enemigo.en_formacion:
				if enemigo.global_position.x > x_mas_derecha:
					x_mas_derecha = enemigo.global_position.x
				if enemigo.global_position.x < x_mas_izquierda:
					x_mas_izquierda = enemigo.global_position.x
	# Si llegaron al límite derecho más el rango, cambia dirección hacia la izquierda
	if x_mas_derecha >= limite_derecho + rango_movimiento:
		direccion_horizontal = -1
	# Si llegaron al límite izquierdo menos el rango, cambia dirección hacia la derecha
	elif x_mas_izquierda <= limite_izquierdo - rango_movimiento:
		direccion_horizontal = 1
	# Mueve todos los enemigos en formación horizontalmente
	for fila in lista_enemigos:
		for enemigo in fila:
			if enemigo != null and is_instance_valid(enemigo):
				enemigo.posicion_formacion.x += paso_horizontal * direccion_horizontal  # Mueve su posición guardada
				if enemigo.en_formacion:  # Si está en formación
					enemigo.global_position.x += paso_horizontal * direccion_horizontal  # Lo mueve realmente
					
*item_hielo.gd*

extends Area2D  # El área que el jugador debe tocar para recoger el item

var velocidad = 60.0  # Velocidad a la que baja el item

func _process(delta):
	position.y += velocidad * delta  # Mueve el item hacia abajo
	if position.y > 380:  # Si sale de la pantalla por abajo
		queue_free()  # Lo elimina

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):  # Si el jugador toca el item
		body.activar_poder_hielo()  # Activa el poder de hielo en el jugador
		queue_free()  # Elimina el item
		
*laser_jugador.gd*

extends Area2D  # El disparo del jugador

var velocidad = 200  # Velocidad a la que sube el laser

func _process(delta):
	position.y -= velocidad * delta  # Mueve el laser hacia arriba

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos"):  # Si el laser toca un enemigo
		body.explotar()  # El enemigo explota
		queue_free()  # Elimina el laser
		
*main.gd*

extends Node  # Escena principal del primer nivel

@onready var fondo_infinito = $ParallaxBackground  # El fondo que se mueve
var velocidad_fondo = 80  # Qué tan rápido se mueve el fondo

func _process(delta: float) -> void:
	fondo_infinito.scroll_offset.y += velocidad_fondo * delta  # Desplaza el fondo hacia abajo

*main_2.gd*

extends Node  # Escena principal del segundo nivel

@onready var fondo_infinito = $ParallaxBackground  # El fondo que se mueve
var velocidad_fondo = 80  # Qué tan rápido se mueve el fondo

func _process(delta: float) -> void:
	fondo_infinito.scroll_offset.y += velocidad_fondo * delta  # Desplaza el fondo hacia abajo
	
*main_3.gd*

extends Node  # Escena principal del tercer nivel

@onready var fondo_infinito = $ParallaxBackground  # El fondo que se mueve
var velocidad_fondo = 80  # Qué tan rápido se mueve el fondo

func _process(delta: float) -> void:
	fondo_infinito.scroll_offset.y += velocidad_fondo * delta  # Desplaza el fondo hacia abajo
	
*misil_boss.gd*

extends Area2D  # El misil que dispara el primer jefe

var velocidad = Vector2.ZERO  # Dirección y velocidad del misil
const VELOCIDAD_BASE = 180  # Velocidad base del misil

func iniciar(direccion: Vector2):
	# Configura la dirección del misil cuando es creado
	velocidad = direccion * VELOCIDAD_BASE  # Multiplica dirección por velocidad base

func _process(delta: float):
	position += velocidad * delta  # Mueve el misil según su velocidad
	# Si sale de la pantalla, lo elimina
	if position.y > 380 or position.y < -20 or position.x < -20 or position.x > 560:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") and body.has_method("explotar"):  # Si toca al jugador
		body.explotar()  # El jugador explota
		queue_free()  # Elimina el misil
		

*misil_enemigo.gd*

extends Area2D  # El misil que disparan los enemigos normales

var speed = 150  # Velocidad a la que baja el misil

func _process(delta):
	position.y += speed * delta  # Mueve el misil hacia abajo
	# Si sale de la pantalla, se elimina solo con el Area2D
	
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("explotar") and body.is_in_group("jugador"):  # Si toca al jugador
		body.explotar()  # El jugador explota
		queue_free()  # Elimina el misil
		
*misil_fuego.gd*

extends Area2D  # El misil de fuego que disparan los jefes 2 y 3

var velocidad = Vector2.ZERO  # Dirección y velocidad del misil

func iniciar(direccion: Vector2):
	velocidad = direccion * 200  # Velocidad base de 200 píxeles por segundo

func _process(delta):
	position += velocidad * delta  # Mueve el misil
	# Si sale de la pantalla, lo elimina
	if position.y > 380 or position.y < -20 or position.x < -20 or position.x > 560:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") and body.has_method("explotar"):  # Si toca al jugador
		body.explotar(25)  # El jugador explota y pierde 25 de vida
		queue_free()  # Elimina el misil
		

*misil_hielo.gd*

extends Area2D  # El misil especial que dispara el jugador cuando tiene el poder de hielo

var velocidad = 200  # Velocidad a la que sube el misil de hielo

func _process(delta):
	position.y -= velocidad * delta  # Mueve el misil hacia arriba
	if position.y < -20:  # Si sale de la pantalla por arriba
		queue_free()  # Lo elimina

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("boss"):  # Si el misil toca a un jefe
		body.recibir_hielo()  # El jefe recibe el efecto de hielo
		queue_free()  # Elimina el misil
		

*navejugador.gd*

extends CharacterBody2D  # Controla la nave del jugador

var laser = preload("res://scenes/laser_jugador.tscn")  # Carga el laser normal

@onready var ptoLaser = $"Punto aparicion laser"  # Punto de donde sale el disparo
@onready var timer_disparo = $TimerDisparo  # Controla la cadencia de disparo
@onready var sprite_explosion = $SpriteEXPLOSION2  # Animación de explosión de la nave

var velocidad = 160  # Velocidad de movimiento de la nave
var puedo_disparar = true  # Si puede disparar en este momento
var vida_prota = 100  # Puntos de vida del jugador

var barra_vida = null  # Referencia a la barra de vida en la interfaz
var mensaje_game_over = null  # Referencia al mensaje de game over

var laser_hielo = preload("res://scenes/misil_hielo.tscn")  # Carga el misil de hielo
var poder_hielo_activo = false  # Si el poder de hielo está activo
var disparos_hielo_restantes = 0  # Cuántos disparos de hielo quedan

func _ready():
	# Busca la barra de vida en los diferentes niveles
	barra_vida = get_node_or_null("/root/Nivel1/BarraVida")
	if barra_vida == null:
		barra_vida = get_node_or_null("/root/main2/BarraVida")
	if barra_vida == null:
		barra_vida = get_node_or_null("/root/Nivel3/BarraVida")
	
	# Busca el mensaje de game over en los diferentes niveles
	mensaje_game_over = get_node_or_null("/root/Nivel1/MensajeGameOver")
	if mensaje_game_over == null:
		mensaje_game_over = get_node_or_null("/root/main2/MensajeGameOver")
	if mensaje_game_over == null:
		mensaje_game_over = get_node_or_null("/root/Nivel3/MensajeGameOver")

	# Configura la barra de vida si existe
	if barra_vida:
		barra_vida.min_value = 0  # Valor mínimo de la barra
		barra_vida.max_value = 100  # Valor máximo de la barra
		barra_vida.value = 100  # Valor actual lleno

func _physics_process(delta):
	# Reinicia la velocidad cada frame
	velocity.x = 0
	velocity.y = 0
	
	# Movimiento con las teclas de flecha
	if Input.is_action_pressed("ui_right"):
		velocity.x = velocidad  # Mueve a la derecha
	if Input.is_action_pressed("ui_left"):
		velocity.x = - velocidad  # Mueve a la izquierda
	if Input.is_action_pressed("ui_down"):
		velocity.y = velocidad  # Mueve hacia abajo
	if Input.is_action_pressed("ui_up"):
		velocity.y = -velocidad  # Mueve hacia arriba
		
	# Disparo con la tecla de espacio o control
	if Input.is_action_just_pressed("disparar") and puedo_disparar == true:
		_disparar()  # Llama a la función de disparo
		puedo_disparar = false  # No puede disparar de nuevo hasta que termine el timer
		timer_disparo.start()  # Arranca el timer de espera
		
	move_and_slide()  # Aplica el movimiento con físicas
	# Detecta colisiones con enemigos
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var colisionador = colision.get_collider()
		if colisionador != null and colisionador.is_in_group("enemigos"):
			colisionador.explotar()  # El enemigo explota
			explotar_por_choque_total()  # El jugador muere al chocar
			return
			
func _on_timer_disparo_timeout() -> void:
	puedo_disparar = true  # Vuelve a poder disparar

func explotar(dano: int = 10):
	vida_prota -= dano  # Resta la vida indicada
	if is_instance_valid(barra_vida):
		barra_vida.value = vida_prota  # Actualiza la barra de vida
	if vida_prota <= 0:  # Si la vida llegó a cero
		set_physics_process(false)  # Detiene el movimiento
		$CollisionShape2D.set_deferred("disabled", true)  # Desactiva colisiones
		$PRONAVE.visible = false  # Oculta la nave
		sprite_explosion.visible = true  # Muestra la explosión
		if is_instance_valid(mensaje_game_over):
			mensaje_game_over.visible = true  # Muestra mensaje de game over
		await get_tree().create_timer(0.5).timeout  # Espera medio segundo
		queue_free()  # Elimina la nave
	else:  # Si todavía tiene vida
		modulate = Color(1, 1, 1, 0.3)  # Se vuelve semitransparente por el golpe
		await get_tree().create_timer(0.1).timeout  # Espera una décima de segundo
		modulate = Color(1, 1, 1, 1)  # Vuelve a la normalidad
		
func _on_detector_choques_body_entered(body: Node2D) -> void:
	if body == self:
		return  # Ignora si es él mismo
	if body != null and body.is_in_group("enemigos"):
		body.explotar()  # El enemigo explota
		if body.is_in_group("kamicase"):  # Si es un enemigo kamikaze
			explotar(50)  # Pierde 50 de vida
		else:  # Si es un enemigo normal
			explotar_por_choque_total()  # Muere instantáneamente
		
func explotar_por_choque_total():
	vida_prota = 0  # La vida se vuelve cero
	if is_instance_valid(barra_vida):
		barra_vida.value = vida_prota  # Actualiza barra
	set_physics_process(false)  # Detiene movimiento
	$CollisionShape2D.set_deferred("disabled", true)  # Desactiva colisiones
	$PRONAVE.visible = false  # Oculta nave
	sprite_explosion.visible = true  # Muestra explosión
	await get_tree().create_timer(2.0).timeout  # Espera 2 segundos
	if is_instance_valid(mensaje_game_over):
		mensaje_game_over.visible = true  # Muestra game over
	queue_free()  # Elimina la nave
	
func reiniciar_vida():
	vida_prota = 100  # Restaura la vida al máximo
	if is_instance_valid(barra_vida):
		barra_vida.value = vida_prota  # Actualiza barra
	modulate = Color(1, 1, 1, 1)  # Vuelve al color normal
	
func activar_poder_hielo():
	poder_hielo_activo = true  # Activa el poder
	disparos_hielo_restantes = 10  # Tiene 10 disparos de hielo
	modulate = Color(0.5, 0.8, 1.0, 1.0)  # Cambia a color azul para indicar poder activo

func _disparar():
	if poder_hielo_activo and disparos_hielo_restantes > 0:  # Si tiene poder de hielo activo
		var l = laser_hielo.instantiate()  # Crea un misil de hielo
		l.global_position = ptoLaser.global_position  # Lo coloca en el punto de disparo
		get_parent().add_child(l)  # Lo agrega a la escena
		disparos_hielo_restantes -= 1  # Reduce los disparos restantes
		if disparos_hielo_restantes <= 0:  # Si ya no quedan disparos de hielo
			poder_hielo_activo = false  # Desactiva el poder
			modulate = Color(1, 1, 1, 1)  # Vuelve al color normal
	else:  # Si no tiene poder de hielo
		var l = laser.instantiate()  # Crea un laser normal
		l.global_position = ptoLaser.global_position  # Lo coloca en el punto de disparo
		get_parent().add_child(l)  # Lo agrega a la escena
		

*nave_blanca.gd*

extends CharacterBody2D  # Controla la nave blanca enemiga

signal nave_eliminada(referencia)  # Avisa cuando la nave es destruida

@onready var sprite_explosion = $SpriteEXPLOSION  # Animación de explosión

var velocidad_y = 120.0  # Velocidad a la que baja la nave

func _process(delta):
	position.y += velocidad_y * delta  # Mueve la nave hacia abajo
	if position.y > 380:  # Si sale de la pantalla por abajo
		queue_free()  # La elimina

func explotar():
	nave_eliminada.emit(self)  # Avisa que la nave murió
	$CollisionShape2D.set_deferred("disabled", true)  # Desactiva colisiones
	$SPRITE.visible = false  # Oculta el sprite de la nave
	sprite_explosion.visible = true  # Muestra explosión
	modulate = Color(1, 1, 1)  # Restaura color por si acaso
	await get_tree().create_timer(0.5).timeout  # Espera medio segundo
	queue_free()  # Elimina la nave
	
	
*nave_rosa.gd*

extends CharacterBody2D  # Controla la nave rosa enemiga que dispara

signal nave_eliminada(referencia)  # Avisa cuando la nave es destruida

var MisilRosa = preload("res://scenes/misil_enemigo.tscn")  # Carga el misil que dispara

@onready var timer_disparo = $TimerDisparo  # Controla cada cuanto dispara
@onready var spawn1 = $SpawnMisil1  # Punto de disparo izquierdo
@onready var spawn2 = $SpawnMisil2  # Punto de disparo derecho
@onready var sprite_explosion = $SpriteEXPLOSION  # Animación de explosión

var velocidad_y = 60.0  # Velocidad lenta a la que baja la nave

func _ready():
	timer_disparo.wait_time = randf_range(0.8, 1.5)  # Tiempo aleatorio entre disparos
	timer_disparo.start()  # Arranca el timer

func _process(delta):
	position.y += velocidad_y * delta  # Mueve la nave hacia abajo lentamente
	if position.y > 380:  # Si sale de la pantalla
		queue_free()  # La elimina

func explotar():
	nave_eliminada.emit(self)  # Avisa que la nave murió
	$CollisionShape2D.set_deferred("disabled", true)  # Desactiva colisiones
	$SPRITE.visible = false  # Oculta el sprite
	sprite_explosion.visible = true  # Muestra explosión
	modulate = Color(1, 1, 1)  # Restaura color
	await get_tree().create_timer(0.5).timeout  # Espera medio segundo
	queue_free()  # Elimina la nave

func _on_timer_disparo_timeout():
	_disparar()  # Dispara
	timer_disparo.wait_time = randf_range(0.8, 1.5)  # Nuevo tiempo aleatorio
	timer_disparo.start()  # Reinicia el timer

func _disparar():
	var misil1 = MisilRosa.instantiate()  # Crea misil izquierdo
	misil1.global_position = spawn1.global_position  # Lo coloca en spawn izquierdo
	get_parent().add_child(misil1)  # Agrega a la escena

	var misil2 = MisilRosa.instantiate()  # Crea misil derecho
	misil2.global_position = spawn2.global_position  # Lo coloca en spawn derecho
	get_parent().add_child(misil2)  # Agrega a la escena
	
	
*pantalla_inicio.gd*

extends Control  # Controla la pantalla de inicio y los menús

@onready var menu_principal = $MenuPrincipal  # Menú principal del juego
@onready var menu_levels = $MenuLevels  # Menú de selección de niveles
@onready var menu_level1 = $MenuLevels1  # Submenú de dificultad para nivel 1
@onready var menu_level2 = $MenuLevels2  # Submenú de dificultad para nivel 2
@onready var menu_level3 = $MenuLevels3  # Submenú de dificultad para nivel 3

func _ready():
	# Muestra solo el menú principal al inicio, oculta los demás
	menu_principal.visible = true
	menu_levels.visible = false
	menu_level1.visible = false
	menu_level2.visible = false
	menu_level3.visible = false
	$MenuPrincipal.get_child(0).grab_focus()  # Enfoca el primer botón del menú principal

func _on_start_normal_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")  # Empieza el nivel 1 normalmente

func _on_levels_pressed():
	menu_principal.visible = false  # Oculta menú principal
	menu_levels.visible = true  # Muestra menú de niveles
	menu_levels.get_child(0).grab_focus()  # Enfoca el primer nivel

func _on_level1_pressed():
	menu_levels.visible = false  # Oculta menú de niveles
	menu_level1.visible = true  # Muestra opciones para nivel 1
	menu_level1.get_child(0).grab_focus()  # Enfoca "Modo Normal"

func _on_level2_pressed():
	menu_levels.visible = false  # Oculta menú de niveles
	menu_level2.visible = true  # Muestra opciones para nivel 2
	menu_level2.get_child(0).grab_focus()  # Enfoca "Modo Normal"

func _on_level3_pressed():
	menu_levels.visible = false  # Oculta menú de niveles
	menu_level3.visible = true  # Muestra opciones para nivel 3
	menu_level3.get_child(0).grab_focus()  # Enfoca "Modo Normal"

func _on_level1_normal_pressed():
	GameState.solo_boss = false  # Modo normal, con oleadas
	get_tree().change_scene_to_file("res://scenes/main.tscn")  # Carga nivel 1

func _on_level1_boss_pressed():
	GameState.solo_boss = true  # Modo solo jefe
	get_tree().change_scene_to_file("res://scenes/main.tscn")  # Carga nivel 1

func _on_level2_normal_pressed():
	GameState.solo_boss = false  # Modo normal, con oleadas
	get_tree().change_scene_to_file("res://scenes/main2.tscn")  # Carga nivel 2

func _on_level2_boss_pressed():
	GameState.solo_boss = true  # Modo solo jefe
	get_tree().change_scene_to_file("res://scenes/main2.tscn")  # Carga nivel 2

func _on_level3_normal_pressed():
	GameState.solo_boss = false  # Modo normal, con oleadas
	get_tree().change_scene_to_file("res://scenes/main3.tscn")  # Carga nivel 3

func _on_level3_boss_pressed():
	GameState.solo_boss = true  # Modo solo jefe
	get_tree().change_scene_to_file("res://scenes/main3.tscn")  # Carga nivel 3

func _on_back_pressed():
	# Vuelve al menú de niveles desde cualquier submenú
	menu_level1.visible = false
	menu_level2.visible = false
	menu_level3.visible = false
	menu_levels.visible = true
	menu_levels.get_child(0).grab_focus()  # Enfoca el primer nivel

func _on_back_levels_pressed():
	# Vuelve al menú principal desde el menú de niveles
	menu_levels.visible = false
	menu_principal.visible = true
	menu_principal.get_child(0).grab_focus()  # Enfoca "Start Normal"
	
	

