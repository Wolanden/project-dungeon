extends Node3D

@onready var player = $Player
@onready var spawns = $Spawns
@onready var navigation_region = $NavigationRegion3D

var zombie = load("res://models/npc/zombie.tscn")
var zombie_instance

func _ready():
	randomize()

func _process(delta):
	if Input.is_action_just_pressed("open_menu"):
		get_tree().change_scene_to_file("res://levels/menu/MainMenu.tscn")

func _physics_process(delta):
	get_tree().call_group("enemies", "UpdateTargetLocation", player.global_transform.origin)

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)

func _on_zombie_spawn_timer_timeout():
	var spawn_point = _get_random_child(spawns).global_position
	zombie_instance = zombie.instantiate()
	zombie_instance.position = spawn_point
	navigation_region.add_child(zombie_instance)
	
	zombie_instance.connect("enemy_died", Callable(player, "_on_zombie_died"))
