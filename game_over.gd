extends CanvasLayer

func _on_restart_pressed() -> void:
	var tree = get_tree()
	tree.paused = false
	Stats.gun_type = 0
	tree.reload_current_scene()
	hide()
