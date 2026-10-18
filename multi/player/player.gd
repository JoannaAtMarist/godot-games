class_name Player
extends Character

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

## Remember the last direction so we can "idle facing" that way if you want later.
var last_dir: Vector2 = Vector2.DOWN

func _physics_process(delta: float) -> void:
	# 1) Read input as a direction vector
	var input_dir := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	# 2) Normalize so diagonals aren't faster
	if input_dir.length() > 0.0:
		input_dir = input_dir.normalized()
		last_dir = input_dir

	# 3) Move (top-down -> no gravity). Use inherited speed from Character.
	velocity = input_dir * speed
	move_and_slide()

	# 4) Pick animation based on direction + whether moving
	_update_animation(input_dir)

## Chooses which animation to play based on movement direction.
func _update_animation(input_dir: Vector2) -> void:
	if input_dir == Vector2.ZERO:
		animated_sprite.stop()
		return

	# Prefer the axis with the biggest magnitude.
	# This prevents jitter when moving diagonally.
	if abs(input_dir.x) > abs(input_dir.y):
		if input_dir.x > 0.0:
			animated_sprite.play("move_right") 
			animated_sprite.play("default")
		else:
			animated_sprite.play("move_left")
			animated_sprite.play("default")
	else:
		if input_dir.y > 0.0:
			animated_sprite.play("move_down")
			animated_sprite.play("default")
		else:
			animated_sprite.play("move_up")
			animated_sprite.play("default")


#region Camera helpers
## ------------------------------------------------------------
## Camera helpers (lets each level decide camera behavior)
## ------------------------------------------------------------

## Configure camera limits from a level script.
## - If enabled == false, we effectively remove limits by using very large bounds.
## - Levels can call this in their _ready() after the Player exists.
func set_camera_limits(enabled: bool, left: int = 0, right: int = 0, top: int = 0, bottom: int = 0) -> void:
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		print("[PLAYER] No Camera2D node found under Player.")
		return

	if enabled:
		camera.limit_left = left
		camera.limit_right = right
		camera.limit_top = top
		camera.limit_bottom = bottom
	else:
		# "No limits" approach: give huge bounds.
		camera.limit_left = -1000000
		camera.limit_right = 1000000
		camera.limit_top = -1000000
		camera.limit_bottom = 1000000

	print("[PLAYER] Camera limits enabled=", enabled,
		" L=", camera.limit_left,
		" R=", camera.limit_right,
		" T=", camera.limit_top,
		" B=", camera.limit_bottom)

## Sets the player's Camera2D zoom.
## Smaller values zoom the camera out, so more of the level is visible.
## Example: Vector2(0.8, 0.8) shows more of the world than Vector2(1.0, 1.0).
func set_camera_zoom(new_zoom: Vector2) -> void:
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		print("[PLAYER] No Camera2D node found under Player.")
		return

	camera.zoom = new_zoom
	print("[PLAYER] Camera zoom set to ", camera.zoom)
#endregion
