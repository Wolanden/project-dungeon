extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var HEALTH_BAR = $SubViewport/Healthbar
@export var PLAYER : CharacterBody3D

var SPEED = 3
var HEALTH = 100
var DAMAGE = 9
var targetReached = false

func _physics_process(delta):
	var currentLocation = global_transform.origin
	var nextLocation = nav_agent.get_next_path_position()
	var newVelocity = (nextLocation - currentLocation).normalized() * SPEED
	
	nav_agent.velocity = newVelocity
	
	if HEALTH <= 0:
		queue_free()
	

func UpdateTargetLocation(targetLocation):
	nav_agent.target_position = targetLocation
	
func TakeDamage(damage):
	HEALTH_BAR._set_health(HEALTH - damage)
	HEALTH -= damage


func _on_navigation_agent_3d_target_reached():
	if nav_agent.distance_to_target() >= 1.75 && nav_agent.distance_to_target() <= 1.8:
		print("Autsch")
		PLAYER.TakeDamage(10)
	#mach damage

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()


func _on_ready():
	HEALTH_BAR._set_health(HEALTH)
