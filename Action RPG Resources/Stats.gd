extends Node

export(int) var maxHealth = 1;
onready var health = maxHealth setget setHealth

func setHealth(val):
	health = val;
	if health <= 0:
		emit_signal("no_health");

signal no_health;

