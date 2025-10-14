extends CanvasLayer

func _on_restart_pressed() -> void:
	var tree = get_tree()
	tree.paused = false
	Stats.gun_type = 0
	tree.reload_current_scene()
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if(get_tree().paused): 
			get_tree().paused = false
			return
		get_tree().paused = true
	
