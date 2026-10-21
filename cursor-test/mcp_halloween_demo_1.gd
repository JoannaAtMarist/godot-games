extends Node2D

@onready var box_cat: AnimatedSprite2D = $BoxCat

func _ready() -> void:
	box_cat.play("box")
