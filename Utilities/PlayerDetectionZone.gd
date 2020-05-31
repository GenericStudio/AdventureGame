extends Area2D

var player = null;

func _on_PlayerDetectionZone_body_entered(body):
	player = body;
	emit_signal("player_seen");

func _on_PlayerDetectionZone_body_exited(body):
	player = null;
	emit_signal("player_lost");


signal player_seen;
signal player_lost;
