extends Control

onready var Empty = $Empty;
onready var Full = $Full;

var textureWidth = 15;
var maxHealth = 5;
var currHealth = 4;

signal no_health;

func _ready():
	Empty.rect_size.x = (maxHealth) * (textureWidth);
	Full.rect_size.x = (currHealth) * (textureWidth);

func hurt(damage):
	currHealth -= damage;
	Full.rect_size.x = (currHealth) * (textureWidth);
	if currHealth <= 0:
		emit_signal("no_health");
	
