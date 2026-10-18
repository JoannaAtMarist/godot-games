class_name GameManager
extends Node

var score = 0
@onready var score_label = $ScoreLabel



func add_point():
	score += 1
	score_label.text = "got" + str(score) + "something"



func become_host():
	print("Become host pressed")
	%MultiplayerHUD.hide()


func join_as_player_2():
	print("Join as player 2")
	%MultiplayerHUD.hide()
