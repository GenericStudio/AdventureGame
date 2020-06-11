extends Node2D

onready var AnimationPlayer = $AnimationPlayer;
onready var TakeSword = $TakeSwordText;
onready var TapSword = get_node("OldMan/Sword/TapSwordText");
onready var SwordGrabSprite = get_node("OldMan/Sword/SwordGrabSprite");

func _ready():
	TapSword.visible = false;
	SwordGrabSprite.visible=false;
	
func loadScene():
	get_tree().change_scene("res://World.tscn")
	
func _on_RichTextLabel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			AnimationPlayer.play("Throw");
			TakeSword.visible = false;
			TapSword.visible = true;
			SwordGrabSprite.visible=true;
			SwordGrabSprite.play();



func _on_RichTextLabel2_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			TapSword.visible = false;
			AnimationPlayer.stop(false);
			SwordGrabSprite.visible=false;
			AnimationPlayer.play("Grabbed")
