extends StaticBody2D

var DeathInstance = preload("DeathInstance.tscn")
onready var stats = $Stats;

func die():
	var _death = DeathInstance.instance();
	get_parent().add_child(_death);
	_death.global_position = global_position;
	queue_free();

func _on_HurtBox_area_entered(area):
	stats.setHealth(stats.health - 1);

func _on_Stats_no_health():
	die();
