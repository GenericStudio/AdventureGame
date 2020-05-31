extends Node2D

var sound = preload("HitSound.tscn");

func _ready():
	print('sound created');
	var _sound = sound.instance();
	add_child(_sound);
	_sound.global_position = global_position;

func _on_AnimatedSprite_animation_finished():
	queue_free();
