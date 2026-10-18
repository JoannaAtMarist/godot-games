extends CharacterBody2D

@export var speed = 400
@export var rotation_speed = 1.5
#const JUMP_VELOCITY = -400.0

var direction = 1
var rotation_direction = 0
@onready var _animated_sprite = $AnimatedSprite2D

# multiplayer player id, defaults at 1
@export var player_id := 1:
	set(id):
		player_id = id
		# set authority to network client id
		%InputSynchronizer.set_multiplayer_authority(id)


func _ready():
	# make sure we're on current client
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false





func _apply_animations(delta):
	if Input.is_action_pressed("move_left"):
		_animated_sprite.flip_h = true
		_animated_sprite.play("default")
	elif Input.is_action_pressed("move_right"):
		_animated_sprite.flip_h = false
		_animated_sprite.play("default")
	elif Input.is_action_pressed("move_up"):
		_animated_sprite.play("default")
	elif Input.is_action_pressed("move_down"):
		_animated_sprite.play("default")
	else:
		_animated_sprite.stop()


func _apply_movement_from_input(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	direction = $InputSynchronizer.input_direction
	velocity = direction * speed
	
	rotation += rotation_direction * rotation_speed * delta
	move_and_slide()







func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_apply_movement_from_input(delta)

	#if not multiplayer.is_server() || MultiplayerManager.host_mode_enabled:
		#_apply_animations(delta)
