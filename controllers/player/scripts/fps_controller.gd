extends CharacterBody3D

@export var BASE_SPEED : float = 5.0
@export var BASE_HEALTH : float = 100.0
@export var SPRINT_MULTIPLIER : float = 2.5
@export var VIEW_BOB_ANIMATION : bool = true
@export var VIEW_BOB_MULTIPLIER : float = 0.1
@export var STRAFE_ANIMATION : bool = true
@export var STRAFE_MULTIPLIER : float = 1
@export var JUMP_VELOCITY : float = 8.5
@export var MOUSE_SENSITIVITY : float = 0.5
@export var HIT_DAMAGE : int = 5

@export var HIT_STAGGER : float = 8.0

@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)

@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATION_PLAYER : AnimationPlayer
@export var WEP_ANIMATION : AnimationPlayer
@export var WEP_HITBOX : Area3D

@onready var HEALTH_BAR = $UI/Healthbar
@onready var hit_rect = $UI/ColorRect
@onready var sword_collider = $CameraController/Camera3D/WeaponPivot/WeaponMesh/Hitbox

var SPEED : float = BASE_SPEED
var HEALTH : float = BASE_HEALTH

var _mouse_input : bool = false
var _mouse_rotation : Vector3
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2

func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _update_camera(delta):
	
	# Rotates camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	CAMERA_CONTROLLER.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	if Input.is_action_just_pressed("attack_h"):
		WEP_ANIMATION.play("H_Attack")
		WEP_HITBOX.monitoring = true
		
	if HEALTH <= 0:
		print("you ded")
	
func _on_hitbox_area_entered(area):
	if area.is_in_group("enemy"):
		area.hit()
		
func _on_weapon_animation_animation_finished(anim_name):
	if anim_name == "H_Attack":
		WEP_ANIMATION.play("idle")
		WEP_HITBOX.monitoring = false

func _physics_process(delta):
	
	_update_camera(delta);
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var current_speed = SPEED
	if Input.is_action_pressed("sprint"):
		current_speed = SPEED * SPRINT_MULTIPLIER
		
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
	handle_walking_animation(input_dir, delta, current_speed)
		
	move_and_slide()

func handle_walking_animation(input_dir, delta, speed):
	if (STRAFE_ANIMATION):
		var strafe_weight = 0.5 * STRAFE_MULTIPLIER
		
		if input_dir.x > 0:
			CAMERA_CONTROLLER.rotation.z = lerp_angle(deg_to_rad(CAMERA_CONTROLLER.rotation.z), deg_to_rad(-5), strafe_weight)
		elif input_dir.x < 0:
			CAMERA_CONTROLLER.rotation.z = lerp_angle(deg_to_rad(CAMERA_CONTROLLER.rotation.z), deg_to_rad(5), strafe_weight)
		else:
			CAMERA_CONTROLLER.rotation.z = lerp_angle(deg_to_rad(CAMERA_CONTROLLER.rotation.z), deg_to_rad(0), strafe_weight)
	
		
	if (VIEW_BOB_ANIMATION):
		if input_dir.y > 0:
			ANIMATION_PLAYER.play("sprint", 0, VIEW_BOB_MULTIPLIER * speed)
		elif input_dir.y < 0:
			ANIMATION_PLAYER.play("sprint", 0, VIEW_BOB_MULTIPLIER * speed)
		else:
			ANIMATION_PLAYER.stop()

func sprinting(state : bool):
	match state:
		true:
			SPEED = BASE_SPEED * SPRINT_MULTIPLIER
		false:
			SPEED = BASE_SPEED

func TakeDamage(damage):
	HEALTH_BAR._set_health(HEALTH - damage)
	HEALTH -= damage

func _on_ready():
	HEALTH_BAR._set_health(BASE_HEALTH)

func hit(dir):
	TakeDamage(HIT_DAMAGE)
	velocity += dir * HIT_STAGGER
	hit_rect.visible = true;
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false;
