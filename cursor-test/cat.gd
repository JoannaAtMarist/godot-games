@tool
extends CharacterBody2D

## Walks back and forth along the room floor, pausing at each end.
## Also builds the "walk" SpriteFrames (7 x 32x32 frames of RunCatt.png,
## 8 FPS, looping) in the editor, so the animation is saved into the
## scene as a SpriteFrames sub-resource.

const FRAME_COUNT := 7
const FRAME_SIZE := 32
const SHEET_PATH := "res://assets/RunCatt.png"

@export var speed: float = 45.0
@export var walk_distance: float = 125.0
@export var pause_time: float = 1.0

var _start_x: float = 0.0
var _direction: float = 1.0
var _pause_timer: float = 0.0
var _editor_built: bool = false

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_ensure_walk_animation()
	if Engine.is_editor_hint():
		return
	_start_x = global_position.x
	_sprite.flip_h = false
	_sprite.play("walk")


func _process(_delta: float) -> void:
	# _ready is not re-run in the editor when a script is (re)attached to a
	# node already in the tree, so build the frames from _process once.
	if Engine.is_editor_hint() and not _editor_built:
		_editor_built = true
		_ensure_walk_animation()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _pause_timer > 0.0:
		_pause_timer -= delta
		velocity = Vector2.ZERO
		move_and_slide()
		if _pause_timer <= 0.0:
			_sprite.play("walk")
		return
	velocity = Vector2(_direction * speed, 0.0)
	move_and_slide()
	if _direction > 0.0 and global_position.x >= _start_x + walk_distance:
		global_position.x = _start_x + walk_distance
		_turn(-1.0)
	elif _direction < 0.0 and global_position.x <= _start_x:
		global_position.x = _start_x
		_turn(1.0)


func _turn(new_direction: float) -> void:
	_direction = new_direction
	_pause_timer = pause_time
	# Sheet faces right: flip only when walking left.
	_sprite.flip_h = _direction < 0.0
	_sprite.pause()


func _ensure_walk_animation() -> void:
	var sprite := _sprite
	if sprite == null:
		sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite == null:
		return
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation("walk") and sprite.sprite_frames.get_frame_count("walk") == FRAME_COUNT:
		return
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("walk")
	frames.set_animation_loop("walk", true)
	frames.set_animation_speed("walk", 8.0)
	var sheet := load(SHEET_PATH) as Texture2D
	if sheet == null:
		return
	for i in FRAME_COUNT:
		var frame_tex := AtlasTexture.new()
		frame_tex.atlas = sheet
		frame_tex.region = Rect2(i * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE)
		frames.add_frame("walk", frame_tex, 1.0)
	sprite.sprite_frames = frames
	sprite.animation = "walk"
