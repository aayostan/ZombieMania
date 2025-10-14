extends CanvasLayer

# Resources section
func RESOURCES():
	pass


var display_text : Array = []
var paused : bool = false



# Built-in section
func BUILTINS():
	pass


func _process(_delta: float) -> void:
	if(not paused and display_text.size() > 0):
		var d_text = display_text.pop_front()
		get_child(0).text = d_text
		show()
		await pause_execution(Stats.DISPLAY_LABEL_TIME)
		hide()



# Helper section
func HELPERS():
	pass

# Input: string (X)
# Process:
	# push text to back of queue
# Output: text queued to be displayed
func queue_display_text(d_text : String):
	display_text.push_back(d_text)


# Input: float (X)
# Process:
	# set paused flag
	# create timer/await timeout
	# reset paused flag
# Output: pauses execution of _process for X seconds, await this
func pause_execution(time : float):
	paused = true
	await get_tree().create_timer(time).timeout
	paused = false
