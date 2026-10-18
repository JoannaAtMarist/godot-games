extends MultiplayerSynchronizer

@onready var player = $".."

var input_direction 


func _ready():
	
	# make sure process and physics process only run on the client
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	
	input_direction = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down")



func _physics_process(delta: float) -> void:
	input_direction = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down")
