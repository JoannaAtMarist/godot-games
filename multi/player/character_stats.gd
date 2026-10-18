class_name CharacterStats
extends Resource
## Base resource class for holding properties common to all characters.

## Movement rate for the character in pixels per second
@export var speed: int

## Maximum amount of health
@export var max_health: int
var current_health: int
## Health recovery rate in points per second
@export var health_recovery: int 

## Maximum amount of magic points pewpew
@export var max_magic: int
var current_magic: int
## Magic recovery rate in points per second
@export var magic_recovery: int 

## Energy cannot exceed this value (unless altered by an effect)
@export var max_energy: int
## Energy recovery rate in points per second
@export var energy_recovery: int 
var current_energy: int
