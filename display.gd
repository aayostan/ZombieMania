extends CanvasLayer

# Resources
var display_text : Array = []
var paused : bool = false

# Built-in
func _process(_delta: float) -> void:
	if(not paused and display_text.size() > 0):
		print("\nDisplay_text size: ", display_text.size())
		
		var d_text = display_text.pop_front()
		print("Displaying: ", d_text)
		get_child(0).text = d_text
		
		show()
		await pause_execution(Stats.DISPLAY_LABEL_TIME)
		print("Await resolved for, ", d_text)
		hide()
		print()


# Helpers

# Input: string (X)
# Process:
	# push text to back of queue
# Output: text queued to be displayed
func queue_display_text(d_text : String):
	display_text.push_back(d_text)


func pause_execution(time : float):
	paused = true
	await get_tree().create_timer(time).timeout
	paused = false
