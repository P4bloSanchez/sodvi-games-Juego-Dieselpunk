extends Control

@onready var menu_principal = $MenuPrincipal
@onready var menu_levels = $MenuLevels
@onready var menu_level1 = $MenuLevels1
@onready var menu_level2 = $MenuLevels2
@onready var menu_level3 = $MenuLevels3

func _ready():
	menu_principal.visible = true
	menu_levels.visible = false
	menu_level1.visible = false
	menu_level2.visible = false
	menu_level3.visible = false
	$MenuPrincipal.get_child(0).grab_focus()

func _on_start_normal_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_levels_pressed():
	menu_principal.visible = false
	menu_levels.visible = true
	# Dar foco al primer botón del menú de niveles
	menu_levels.get_child(0).grab_focus()

func _on_level1_pressed():
	menu_levels.visible = false
	menu_level1.visible = true
	menu_level1.get_child(0).grab_focus()

func _on_level2_pressed():
	menu_levels.visible = false
	menu_level2.visible = true
	menu_level2.get_child(0).grab_focus()

func _on_level3_pressed():
	menu_levels.visible = false
	menu_level3.visible = true
	menu_level3.get_child(0).grab_focus()

func _on_level1_normal_pressed():
	GameState.solo_boss = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_level1_boss_pressed():
	GameState.solo_boss = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_level2_normal_pressed():
	GameState.solo_boss = false
	get_tree().change_scene_to_file("res://scenes/main2.tscn")

func _on_level2_boss_pressed():
	GameState.solo_boss = true
	get_tree().change_scene_to_file("res://scenes/main2.tscn")

func _on_level3_normal_pressed():
	GameState.solo_boss = false
	get_tree().change_scene_to_file("res://scenes/main3.tscn")

func _on_level3_boss_pressed():
	GameState.solo_boss = true
	get_tree().change_scene_to_file("res://scenes/main3.tscn")

func _on_back_pressed():
	menu_level1.visible = false
	menu_level2.visible = false
	menu_level3.visible = false
	menu_levels.visible = true
	# Volver al foco del menú de niveles
	menu_levels.get_child(0).grab_focus()

func _on_back_levels_pressed():
	menu_levels.visible = false
	menu_principal.visible = true
	# Volver al foco del menú principal
	menu_principal.get_child(0).grab_focus()
