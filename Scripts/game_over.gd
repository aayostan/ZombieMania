extends CanvasLayer


# Resource section
func RESOURCES():
	pass


var state : int = 0
enum states {
	START,
	PAUSE,
	END
}
var label
var button


# Built-in section
func BUILTINS():
	pass


func _ready() -> void:
	state = states.START
	label = find_child("Label")
	button = find_child("Button")
	button.text = "Start"
	label.text = "Ready?"
	get_tree().paused = true
	visible = true


# Events section
func EVENTS():
	pass


func _on_button_pressed() -> void:
	var tree = get_tree()
	tree.paused = false
	
	if(state == states.START):
		button.text = "Restart"
		state = states.PAUSE
		label.text = "Game Over"
	else:
		Stats.gun_type = 0
		tree.reload_current_scene()
	
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and state == states.PAUSE:
			if(get_tree().paused): 
				visible = false
				label.text = "Game Over"
				get_tree().paused = false
				return
			get_tree().paused = true
			label.text = "Paused"
			visible = true
	
