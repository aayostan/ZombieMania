extends Node2D


# Helper section
func HELPERS():
	pass


func play_idle_animation():
	%AnimationPlayer.play("idle")


func play_walk_animation():
	%AnimationPlayer.play("walk")
