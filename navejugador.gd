extends CharacterBody2D

var laser = preload("res://scenes/laser_jugador.tscn")

@onready var ptoLaser = $"Punto aparicion laser"
@onready var timer_disparo = $TimerDisparo
@onready var sprite_explosion = $SpriteEXPLOSION2

var velocidad = 160 
var puedo_disparar = true
var vida_prota = 100

var barra_vida = null
var mensaje_game_over = null

var laser_hielo = preload("res://scenes/misil_hielo.tscn")
var poder_hielo_activo = false
var disparos_hielo_restantes = 0

func _ready():
	barra_vida = get_node_or_null("/root/Nivel1/BarraVida")
	if barra_vida == null:
		barra_vida = get_node_or_null("/root/main2/BarraVida")
	if barra_vida == null:
		barra_vida = get_node_or_null("/root/Nivel3/BarraVida")
	
	mensaje_game_over = get_node_or_null("/root/Nivel1/MensajeGameOver")
	if mensaje_game_over == null:
		mensaje_game_over = get_node_or_null("/root/main2/MensajeGameOver")
	if mensaje_game_over == null:
		mensaje_game_over = get_node_or_null("/root/Nivel3/MensajeGameOver")

	if barra_vida:
		barra_vida.min_value = 0
		barra_vida.max_value = 100
		barra_vida.value = 100

func _physics_process(delta):
	velocity.x = 0
	velocity.y = 0
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = velocidad
	if Input.is_action_pressed("ui_left"):
		velocity.x = - velocidad
	if Input.is_action_pressed("ui_down"):
		velocity.y = velocidad
	if Input.is_action_pressed("ui_up"):
		velocity.y = -velocidad
		
	if Input.is_action_just_pressed("disparar") and puedo_disparar == true:
		_disparar()
		puedo_disparar = false
		timer_disparo.start()
		
	move_and_slide()
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var colisionador = colision.get_collider()
		if colisionador != null and colisionador.is_in_group("enemigos"):
			colisionador.explotar()
			explotar_por_choque_total()
			return
			
func _on_timer_disparo_timeout() -> void:
	puedo_disparar = true
	
func explotar(dano: int = 10):
	vida_prota -= dano
	if is_instance_valid(barra_vida):
		barra_vida.value = vida_prota
	if vida_prota <= 0:
		set_physics_process(false)
		$CollisionShape2D.set_deferred("disabled", true)
		$PRONAVE.visible = false
		sprite_explosion.visible = true
		if is_instance_valid(mensaje_game_over):
			mensaje_game_over.visible = true
		await get_tree().create_timer(0.5).timeout
		queue_free()
	else:
		modulate = Color(1, 1, 1, 0.3)
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1, 1)
		
func _on_detector_choques_body_entered(body: Node2D) -> void:
	if body == self:
		return
	if body != null and body.is_in_group("enemigos"):
		body.explotar()
		if body.is_in_group("kamicase"):
			explotar(50)
		else:
			explotar_por_choque_total()
		
func explotar_por_choque_total():
	vida_prota = 0
	if is_instance_valid(barra_vida):
		barra_vida.value = vida_prota
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$PRONAVE.visible = false
	sprite_explosion.visible = true
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(mensaje_game_over):
		mensaje_game_over.visible = true
	queue_free()
	
func reiniciar_vida():
	vida_prota = 100
	if is_instance_valid(barra_vida):
		barra_vida.value = vida_prota
	modulate = Color(1, 1, 1, 1)
	
func activar_poder_hielo():
	poder_hielo_activo = true
	disparos_hielo_restantes = 10
	modulate = Color(0.5, 0.8, 1.0, 1.0)  # tinte azul para indicar poder activo

func _disparar():
	if poder_hielo_activo and disparos_hielo_restantes > 0:
		var l = laser_hielo.instantiate()
		l.global_position = ptoLaser.global_position
		get_parent().add_child(l)
		disparos_hielo_restantes -= 1
		if disparos_hielo_restantes <= 0:
			poder_hielo_activo = false
			modulate = Color(1, 1, 1, 1)
	else:
		var l = laser.instantiate()
		l.global_position = ptoLaser.global_position
		get_parent().add_child(l)
