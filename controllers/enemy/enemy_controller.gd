extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

var SPEED = 3
var HEALTH = 20
var targetReached = false


func _physics_process(delta):
	var currentLocation = global_transform.origin
	var nextLocation = nav_agent.get_next_path_position()
	var newVelocity = (nextLocation - currentLocation).normalized() * SPEED
	
	nav_agent.velocity = newVelocity 
	

func UpdateTargetLocation(targetLocation):
	nav_agent.target_position = targetLocation
	


func _on_navigation_agent_3d_target_reached():
	if nav_agent.distance_to_target() >= 2.05 && nav_agent.distance_to_target() <= 2.1:
		print("Autsch")
	#mach damage

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()
