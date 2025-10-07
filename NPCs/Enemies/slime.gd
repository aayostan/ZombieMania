extends Node2D


func play_walk():
	%AnimationPlayer.play("walk")


func play_hurt():
	if Stats.run_tests:
		print()
		print("Playing hurt")
		print("Base Modulate: ", find_child("SlimeBody").modulate)
	%AnimationPlayer.play("hurt")
	%AnimationPlayer.queue("walk")
