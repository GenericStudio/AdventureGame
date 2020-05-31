extends AudioStreamPlayer2D

func _ready():
	play();

func _on_SoundEffect_finished():
	queue_free();
