extends CanvasLayer

signal no_health
signal full_health
signal health_healing
signal health_hurting

onready var full = $Control/Full;
onready var empty = $Control/Empty;

var textureWidth = 15;

var currHealth = 4;
var maxHealth = 10;

func _ready():
	full.rect_size.x = currHealth * textureWidth;
	empty.rect_size.x = maxHealth * textureWidth;
	
func hurt(damage=1):
	currHealth -= damage;
	if(currHealth <= 0):
		emit_signal("no_health");
	full.rect_size.x = currHealth * textureWidth;
