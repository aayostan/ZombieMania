extends Node

var _player_health : float = 100.0
var player_health: float:
	get:
		return _player_health
	set(value):
		_player_health = clampf(value, 0, 100) # Ensure health stays between 0 and 100

var _player_speed : float = 600.0
var player_speed: float:
	get:
		return _player_speed
	set(value):
		_player_speed = clampf(value, 600.0, 1600.0) # Ensure gun_count stays between 600 and 1600

var two_guns : bool = false
var guns : Array = []
var gun_type = 0 # Originally pistol
#var _gun_count : int = 1
#var gun_count: int:
	#get:
		#return _gun_count
	#set(value):
		#_gun_count = clamp(value, 1, 2) # Ensure gun_count stays between 1 and 4

var game_round : int = 1
@export var enemy_damage = 10.0
@export var pickup_probability = 1
