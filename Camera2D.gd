extends Camera2D


onready var TopLeft = $Limits/TopLeft;
onready var BottomRight = $Limits/BottomRight;
# Called when the node enters the scene tree for the first time.
func _ready():
	limit_bottom = BottomRight.global_position.y;
	limit_right = BottomRight.global_position.x;
	limit_top = TopLeft.global_position.y;
	limit_left = TopLeft.global_position.x;
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
