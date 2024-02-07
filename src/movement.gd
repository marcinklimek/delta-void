extends CharacterBody3D

const SPEED = 9
const JUMP_VELOCITY = 8
const FALL_VEL = -12
const DASH_SPEED = 40
const DASH_TIME = 0.2
const DASH_COOLDOWN = 0.5
const super_jump = 8

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var vector = Vector3()
var is_dashing = false
var dash_timer = 0.0
var can_dash = true

@onready var camera := $camera/Camera3D
@onready var player_body := $MeshInstance3D  # Assuming you have a node named MeshInstance3D under your main character node

var last_rotation_angle = 0  # Variable to store the last rotation angle

func _process(delta):
	# Handle Dash cooldown
	if not can_dash:
		dash_timer += delta
		if dash_timer >= DASH_COOLDOWN:
			can_dash = true
			dash_timer = 0.0

	# Handle Dash
	if Input.is_action_pressed("shift") and can_dash and (velocity.x != 0 or velocity.z != 0):
		is_dashing = true
		can_dash = false
		dash_timer = 0.0
	if Input.is_action_just_pressed("f") and can_dash:
		can_dash = false
		dash_timer = -1
		velocity.y = super_jump

	if is_dashing:
		var dash_direction = Vector3(velocity.x, 0, velocity.z).normalized()
		if dash_direction == Vector3.ZERO:
			dash_direction = transform.basis.z.normalized()

		velocity = dash_direction * DASH_SPEED

		dash_timer += delta
		if dash_timer >= DASH_TIME:
			is_dashing = false
			velocity = Vector3(velocity.x, 0, velocity.z)

	# Handle Gravity and Jump
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("ctrl"):
		velocity.y = FALL_VEL

	# Handle Rotation based on movement keys
	var rotation_angle = 0

	if Input.is_action_pressed("w"):
		rotation_angle += 0
	if Input.is_action_pressed("a"):
		rotation_angle += 90
	if Input.is_action_pressed("s"):
		rotation_angle += 180
	if Input.is_action_pressed("d"):
		rotation_angle += -90

	if Input.is_action_pressed("w") and Input.is_action_pressed("a"):
		rotation_angle += -45
	if Input.is_action_pressed("w") and Input.is_action_pressed("d"):
		rotation_angle += 45
	if Input.is_action_pressed("s") and Input.is_action_pressed("a"):
		rotation_angle += -145
	if Input.is_action_pressed("s") and Input.is_action_pressed("d"):
		rotation_angle += 145

	player_body.rotation_degrees.y = rotation_angle

	# Handle Movement
	var input_dir = Input.get_vector("s", "w", "a", "d")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction and not is_dashing:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		# Update the last rotation angle when moving
		last_rotation_angle = rotation_angle
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

		# Use the last rotation angle when not moving
		player_body.rotation_degrees.y = last_rotation_angle

	move_and_slide()
