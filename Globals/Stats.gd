extends Node


const PLAYER_LEVEL_START : int = 2
const GAME_ROUND_START : int = 1

const DISPLAY_LABEL_TIME : float = 3.2


# Flags
var run_tests = false

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
@export var pickup_probability = .5


# Resources
enum pickup {
	SODA,
	SANDWHICH,
	GUN
}

const PICKUP_PARAMS = [
	{
		"name" = "Soda",
		"stat" = "speed",
		"modifier" = "multiply",
		"value" = 1.5,
		"cooldown" = 12,
		"spritepath" = "res://Pickups/soda_can.png",
		"scale" = Vector2(0.05,0.05),
		"g_mod" = 0.05,
		"sfx" = "PUSo",
		"lifetime" = 5
	}, 
	{
		"name" = "Sandwhich",
		"stat" = "health",
		"modifier" = "add",
		"value" = 10,
		"cooldown" = 0,
		"spritepath" = "res://Pickups/sandwhich.png",
		"scale" = Vector2(0.1,0.1),
		"g_mod" = 0.1,
		"sfx" = "PUSa",
		"lifetime" = 10
	},
	{
		"name" = "Gun",
		"stat" = "gun",
		"modifier" = "add",
		"value" = 1,
		"cooldown" = 15,
		"spritepath" = "res://Player/Gun/pistol.png",
		"scale" = Vector2(1,1),
		"g_mod" = 1,
		"sfx" = "GunSwitch",
		"lifetime" = 8
	}
]
