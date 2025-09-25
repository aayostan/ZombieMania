extends Area2D

# Each pickup has it's own bonus (affects one of the stats of the players or enemeies)
	# need communicate with each class
# Each pickup has it's own cooldown time
	# need create timer and respond to timeout
# Each pickup has it's own probability of being dropped by an enemy
	# Need to define paramaters of instantiation in enemy
# Each pickup has it's own sound
	# Need to create and define, easy global access.

const PICKUP_PARAMS = [
	{
		"stat" = "speed",
		"modifier" = "multiply",
		"value" = 1.5,
		"cooldown" = 12,
		"spritepath" = "res://Pickups/soda_can.png",
		"scale" = Vector2(0.05,0.05),
		"sfx" = "PUSo",
		"lifetime" = 5
	}, 
	{
		"stat" = "health",
		"modifier" = "add",
		"value" = 10,
		"cooldown" = 0,
		"spritepath" = "res://Pickups/sandwhich.png",
		"scale" = Vector2(0.1,0.1),
		"sfx" = "PUSa",
		"lifetime" = 10
	},
	{
		"stat" = "gun",
		"modifier" = "add",
		"value" = 1,
		"cooldown" = 15,
		"spritepath" = "res://Player/Gun/pistol.png",
		"scale" = Vector2(1,1),
		"sfx" = "N/A",
		"lifetime" = 8
	}
]

enum pickup {
	CAFFEINE,
	SANDWHICH,
	GUN
}

var param

# Has to start as true to bounce at all
var bouncing
var pf2d
var bi = 0

@export var growth_scale : float = 0.1 
@export var radius_range : Vector2 = Vector2(1080/2.0, 1920/2.0)
@export var min_speed : float = 1

func _ready():
	# Choose random pickup and change visuals
	var p = "GUN"#pickup.keys()[randi() % pickup.size()]
	param = PICKUP_PARAMS[pickup[p]]
	%Sprite2D.texture = load(param["spritepath"])
	%Sprite2D.scale = param["scale"]
	setup_bounce()


func _process(delta : float) -> void:
	if(bouncing):
		bouncer(delta)
	else:
		# Turn collision detection back on after bouncing
		# and create timer for lifetime of pickup
		# release path resources
		if(monitoring == false):
			monitoring = true
			get_tree().create_timer(param['lifetime']).timeout.connect(_on_lifetime_end)
			pf2d.get_parent().queue_free()
	


func setup_bounce():
	bouncing = true
	var radius = randf_range(radius_range.x, radius_range.y)
	
	# This should turn off collision detection while bouncing
	monitoring = false
	
	# Create Path2D
	var p2d = Path2D.new()
	get_parent().add_child(p2d)
	p2d.curve = Curve2D.new()
	p2d.curve.add_point(global_position)
	p2d.curve.add_point(global_position + _random_inside_circle(radius))

	# Create PathFollow2D
	pf2d = PathFollow2D.new()
	p2d.add_child(pf2d)
	pf2d.progress_ratio = 0


func bouncer(delta : float):
	# Let's start with just going left and right with inverted parabola
	# then maybe I can figure out how to change it's scale
	# I can do a radius which defines a point on a circle around the mob destroyed location
	# I cannot follow an inverted parabola to that point.
	# It is a top down view... so we are looking down at the playing field
	# Objects that bounce out from another object would look like they were coming into the camera
	# Their scale wouuld follow on an inverted parabola with linear decay
	# How would I calculate that? It isn't constant linear decay, it's more step like, almost inverse exponential
	# programmatically, you could rep this with halving the height each time it reaches zero.
	# One variables follows an inverted parabola, the scale 
	# and the other variable follows a regular parabola the speed of movement (i.e. distance along path)
	# The two inputs are progress_ratio (0->1), and the time between frames (~0.01666)
	# The ouput should move the pickup along path and change scale accordingly
	# The output for pathfollow can be from 0 to 1 where 0 is path start and 1 is path end
	# It's behavior should be parabolic, reaching the valley at 0.5
	# The ouput for scale should be a parabola (when path = 0.5, parabola should be at it's peak)
	
	var bounce = [
		{ # 1
			"height" = 1,
			"width" = 3,
			"disp" = 1,
			"speed" = 0.5
		}, 
		{ # 2
			"height" = 0.35,
			"width" = 4,
			"disp" = 3.25,
			"speed" = 1 - 0.35
		}
	]
	
	var bounce_p
	var prev_pr : float
	var new_pr : float 
	var growth : float 
	var growth_v : Vector2

	if(bi >= bounce.size()):
		new_pr = 1
		growth = -1
	else:
		bounce_p = bounce[bi]
		prev_pr = pf2d.progress_ratio
		new_pr = prev_pr + delta * _parabola(prev_pr, bounce_p['speed'], bounce_p['width'], bounce_p['disp'])
		growth = growth_scale * _parabola(prev_pr, bounce_p['height'], bounce_p['width'], bounce_p['disp'], true)
		growth_v = Vector2(growth, growth)

	# the rate of change of pr should change over time
	if(new_pr >= 1):
		pf2d.progress_ratio = 1
		bouncing = false
	else:
		pf2d.progress_ratio = new_pr
	
	global_position = pf2d.global_position 
	
	if(growth < 0):
		%Sprite2D.scale = param['scale']
		bi += 1
	else:
		%Sprite2D.scale = param['scale'] + growth_v


func _random_inside_circle(radius: float) -> Vector2:
	return _random_inside_unit_circle() * radius


# Courtesy of https://www.reddit.com/r/godot/comments/vjge0n/could_anyone_share_some_code_for_finding_a/ @angelonit
func _random_inside_unit_circle() -> Vector2:
	var theta : float = randf() * 2 * PI
	return Vector2(cos(theta), sin(theta)) * sqrt(randf())


func _inverted_parabola_from_origin(curr_x: float, disp : float, height : float) -> float:
	return _parabola(curr_x, height, 1, disp + sqrt(height), true)


func _parabola(curr_x : float, height : float, width : float, disp : float, inverted : bool = false) -> float:
	if(inverted):
		return -((width * curr_x) - disp)**2 + height
	else:
		return ((width * curr_x) - disp)**2 + height


func _on_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		AudioManager.play_sfx(param['sfx'],0,true)
		create_connect()
		update_stat(body)
		queue_free()


func create_connect():
	var tree = get_tree()
	if(param['cooldown'] > 0):
		var timer = tree.create_timer(param['cooldown'])
		var game = get_parent()
		timer.timeout.connect(game._on_pickup_cooldown.bind(param))


func update_stat(body):
	if(param["stat"] == "speed"):
		if(param["modifier"] == "add"):
			Stats.player_speed += param["value"]
		else:
			Stats.player_speed *= param["value"]
	elif(param["stat"] == "health"):
		if(param["modifier"] == "add"):
			Stats.player_health += param["value"]
		else:
			Stats.player_health *= param["value"]
	elif(param["stat"] == "gun"):
		if(param["modifier"] == "add"):
			body.create_gun()
			Stats.two_guns = true


func _on_lifetime_end():
	queue_free()
