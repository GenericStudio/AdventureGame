extends Node2D

var DeathInstance = preload("DeathInstance.tscn")
var HitInstance = preload("HitInstance.tscn");
onready var stats = $Stats;

func die():
	var _death = DeathInstance.instance();
	get_parent().add_child(_death);
	_death.global_position = global_position;
	queue_free();

func _on_HurtBox_area_entered(area):
	stats.setHealth(stats.health - 1);
	var _hit = HitInstance.instance();
	area.add_child(_hit);
	_hit.global_position = _hit.global_position.move_toward(global_position, _hit.global_position.distance_to(global_position)/2);

func _on_Stats_no_health():
	die();
