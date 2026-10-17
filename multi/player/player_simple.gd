extends CharacterBody2D

@export var speed = 400
@export var rotation_speed = 1.5
const JUMP_VELOCITY = -400.0

var rotation_direction = 0
@onready var _animated_sprite = $AnimatedSprite2D


func get_input():
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector(
		"move_left", "move_right", "move_up", "move_down")
	# set velocity
	velocity = direction * speed


func _process(_delta):
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


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	get_input()
	rotation += rotation_direction * rotation_speed * delta
	move_and_slide()
