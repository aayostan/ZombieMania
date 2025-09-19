extends Node

var active_music: AudioStreamPlayer
var active_sfx : AudioStreamPlayer

func _ready():
	#play_music("Main")
	pass

func play_music(clip_name: String, position: float = 0):
	if active_music and active_music.playing:
		active_music.stop()
	active_music = %Music.get_node(clip_name)
	active_music.play(position)

var xp_index := 0	
var pitch_array := [ .8, .9, 1, 1.2, 1.3]
func play_sfx(clip_name: String, 
				position: float = 0, 
				playMultiple: bool = false, 
				scale_pitch : bool = false,
				rand_pitch: bool = false
			):
	active_sfx = %Sfx.get_node(clip_name)
	if(active_sfx):
		if !active_sfx.playing or playMultiple:
			active_sfx.play(position)
			if(scale_pitch):
				active_sfx.pitch_scale = pitch_array[xp_index]
				xp_index += 1
				if xp_index >= pitch_array.size():
					xp_index = 0
			elif(rand_pitch):
					active_sfx.pitch_scale = pitch_array[randi() % 5]
