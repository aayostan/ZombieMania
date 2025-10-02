extends Node

func search_params(arr : Array, nam : String) -> Dictionary:
	var has_name = false
	for item in arr:
		for key in item.keys():
			if key == "name":
				has_name = true
		if has_name:
			if(item["name"] == nam):
				return item
	return {}


func _random_inside_circle(radius: float) -> Vector2:
	return _random_inside_unit_circle() * radius


# Courtesy of https://www.reddit.com/r/godot/comments/vjge0n/could_anyone_share_some_code_for_finding_a/ @angelonit
func _random_inside_unit_circle() -> Vector2:
	var theta : float = randf() * 2 * PI
	return Vector2(cos(theta), sin(theta)) * sqrt(randf())


# Input: List of probabilities betwee 0 and 1 adding to 1 (length: X)
# Input: List of items (length: X)
# Process:
	# Check lists are same sized
	# Check probs adds up to 1
	# Choose item based on probability
# Output: item of choice (-1 if error)
func _choose_random_w_probs(probs : Array, items : Array):
	# Error checking 1
	if(probs.size() != items.size()):
		printerr("probs and items arrays not same size")
		return -1
	
	# Error checking 2
	var run_sum = 0
	for prob in probs:
		run_sum += prob
	if(not is_equal_approx(run_sum, 1.0)):
		print("_choose_random_w_probs: probs sum != 1")
	
	# Choose item
	var rand = randf_range(0,run_sum)
	run_sum = 0
	var idx = 0
	for prob in probs:
		if(rand >= run_sum and rand < run_sum + prob):
			return items[idx]
		run_sum += prob
		idx += 1
