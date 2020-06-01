extends StaticBody2D

onready var NavManager = get_tree().get_nodes_in_group("NavigationMap")[0] as Navigation2D;
onready var cutout = $CollisionPolygon2D;

func _ready():
	NavManager.Holes.append(cutout);
	
