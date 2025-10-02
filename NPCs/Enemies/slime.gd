extends Node2D


func play_walk():
	%AnimationPlayer.play("walk")


func play_hurt():
	print()
	print("Playing hurt")
	print("Base Modulate: ", find_child("SlimeBody").modulate)
	%AnimationPlayer.play("hurt")
	%AnimationPlayer.queue("walk")
