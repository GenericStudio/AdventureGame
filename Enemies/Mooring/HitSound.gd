extends AudioStreamPlayer2D

func _ready():
	play();


func _on_Sound_finished():
	queue_free()
