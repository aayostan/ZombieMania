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
