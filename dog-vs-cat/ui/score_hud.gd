extends Control

@onready var score_label: Label = $Label


func _ready() -> void:
	MultiplayerManager.score_updated.connect(_on_score_updated)

func _on_score_updated(player_id: int, new_score: int) -> void:
	# Update the label if this score belongs to the local player instance
	if player_id == multiplayer.get_unique_id():
		score_label.text = "Score: %d" % new_score
