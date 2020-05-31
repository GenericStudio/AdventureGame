extends AudioStreamPlayer2D

func _ready():
	print('play');
	play();


func _on_Sound_finished():
	print('remove');
	queue_free()
