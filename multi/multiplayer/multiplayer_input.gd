extends MultiplayerSynchronizer


var input_direction 


func _ready():
	input_direction = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down")



func _physics_process(delta: float) -> void:
	input_direction = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down")
