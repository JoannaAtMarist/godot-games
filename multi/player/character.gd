class_name Character
extends CharacterBody2D
## Base class for all game characters, whether player or AI-controlled.

# an exported property to hold an CharacterStats resource
@export var stats:CharacterStats

## Movement rate for the character in pixels per second.
@export var speed = 300

# Base attack hooks.
# Some subclasses may use built-in hitboxes on the character itself.
# Other subclasses, such as the player, may spawn an external attack scene.
var melee: Node = null

func attack():
	# Override in subclasses to perform melee (e.g. enable hitbox, play animation).
	pass


func shoot() -> void:
	# Override in subclasses to perform ranged attack using the character's own logic.
	if not has_node("AttackOrigin"):
		return
	# No external ranged scene; subclasses implement as needed.
	pass


func take_hit(damage:int):
	if stats == null:
		return
	stats.current_health -= damage
	if stats.current_health <= 0:
		_on_death()


## Override in subclasses to customize death (e.g. emit signals, play animation) instead of queue_free.
func _on_death() -> void:
	queue_free()


func _ready() -> void:
	# --- Initialize stats safely ---
	if stats != null:
		if stats.current_health <= 0:
			stats.current_health = stats.max_health
		if stats.current_magic <= 0:
			stats.current_magic = stats.max_magic
		if stats.current_energy <= 0:
			stats.current_energy = stats.max_energy


func _process(_delta):
	pass


func _physics_process(delta):
	move_and_collide(velocity * delta)
