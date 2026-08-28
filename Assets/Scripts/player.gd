class_name Player
extends CharacterBody3D

# One meter here equals one unit in ULTRAKILL
## The speed the character moves when walking normally
@export var walkSpeed: float = 16.5 # m/s = ULTRAKILL u/s
## The speed the character moves when holding ctrl
@export var slideSpeed: float = 24
## The speed the character moves when doing a dash
@export var dashSpeed: float = 49.5
@export var slideJumpSpeedMult: float = 2
## how hard the player can strafe laterally while sliding
@export var slideStrafeForce: float = 3.0
## The strength of gravity
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
## The height the character jumps to
@export var jump_height: float = 1 # m
@export var camera_sens: float = 1

var jumping: bool = false
var mouse_captured: bool = false

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

var isDashing: bool = false
var dashLockDir: Vector3 = Vector3.ZERO
## how many frames the user has been sliding for
var slideTime: int = 0
var slamming: bool = false

@onready var camera: Camera3D = $Camera

func _ready() -> void:
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&"jump"): jumping = true
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	move_and_slide()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	
	if Input.is_action_just_pressed("dash") and not Input.is_action_pressed("slide") and not isDashing:
		startDash(walk_dir) # Instantly starts a new dash
	
	var cam_forward = -camera.global_transform.basis.z
	if isDashing:
		# Lock vertical movement during the active frames
		velocity.y = 0 
		# Dash uses the saved lock direction vector, or camera forward if neutral
		if dashLockDir != Vector3.ZERO:
			walk_vel = dashLockDir * dashSpeed
		else:
			var flat_forward = Vector3(cam_forward.x, 0, cam_forward.z).normalized()
			walk_vel = flat_forward * dashSpeed
	elif not slamming:
		# move at walking speed if not sliding or dashing
		if not Input.is_action_pressed("slide") and not slamming:
			slideTime = 0
			walk_vel = walk_dir * walkSpeed * move_dir.length()
			slideVFX(false)
		elif Input.is_action_pressed("slide") and is_on_floor() and not slamming:
			if slideTime <= 3: 
				walk_vel *= slideJumpSpeedMult
			handleSlide(walk_dir, cam_forward)
			slideTime += 1
		elif Input.is_action_just_pressed("slide") and not is_on_floor(): slamming = true
	
	if slamming:
		walk_vel = Vector3.ZERO
		walk_vel.y = -100
		if is_on_floor(): slamming = false
	
	return walk_vel

func handleSlide(walk_dir: Vector3, cam_forward: Vector3):
	if Input.is_action_just_pressed("slide"):
		# Lock the initial movement direction (or forward if standing still)
		dashLockDir = walk_dir if walk_dir != Vector3.ZERO else cam_forward
	
	
	# 1. Base slide velocity along the locked path
	var base_slide_vel = dashLockDir * slideSpeed
	
	# 2. Calculate the direct left/right push
	# Extract the camera's true right vector, flattening the Y axis so they don't push into the ground
	var cam_right: Vector3 = Vector3(camera.global_transform.basis.x.x, 0, camera.global_transform.basis.x.z).normalized()
	
	# move_dir.x is negative for A (left) and positive for D (right)
	var side_push_vel = cam_right * move_dir.x * slideStrafeForce
	
	# 3. Combine them. The player moves along the locked path, plus any active side force
	walk_vel = base_slide_vel + side_push_vel
	slideVFX(true, walk_vel.normalized())

func slideVFX(enabled: bool, move_direction: Vector3 = Vector3.ZERO):
	if enabled:
		$StandingCollider.disabled = true
		$SlidingCollider.disabled = false
		camera.position.y = 1.7 - 0.9
		if is_on_floor():
			var spark_dir = move_direction 
			spark_dir.y = 0.25
			spark_dir = spark_dir.normalized()
			
			$SlideSparks.direction = $SlideSparks.global_transform.basis.inverse() * spark_dir
			$SlideSparks.emitting = true
		else:
			$SlideSparks.emitting = false
	else:
		$StandingCollider.disabled = false
		$SlidingCollider.disabled = true
		camera.position.y = 1.7
		$SlideSparks.emitting = false

func startDash(initial_dir: Vector3):
	isDashing = true
	dashLockDir = initial_dir # Freeze the movement vector
	$dashTimer.start()
	
	await $dashTimer.timeout
	isDashing = false

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() or is_on_ceiling_only() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel
