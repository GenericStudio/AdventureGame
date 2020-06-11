extends KinematicBody2D

### Navigation
onready var Graph = get_node("Node/Graph");
onready var Line = get_node("Node/Line2D");
onready var destination = global_position;

var path = null;
var pathAttentionIndex = 0;

var invulnerable = false;

const max_speed = 300;
const acceleration = 50;

var velocity = Vector2.ZERO;
var state = MOVE;
var rollVector = Vector2.DOWN;

var MOVE_TYPE = DIRECT;

onready var swordHitBox = $SwordRoot/HitBox

onready var effectsPlayer = $SpriteEffectAnimations
onready var animationTree = $AnimationTree
onready var HealthManager = $Health;
onready var animationState = animationTree.get("parameters/playback");

enum {
	MOVE,
	ROLL,
	ATTACK,
	DIRECT,
	NAVIGATION
}

## GODOT 
func _ready():
	animationTree.active=true;
	swordHitBox.knockBackVector = Vector2.DOWN;

func _physics_process(delta):
	match state:
		MOVE:
			MoveState(delta);
			
		ROLL:
			RollState(delta);
			
		ATTACK:
			AttackState(delta);

func _input(event):
	if event.is_action_pressed('click'):

		Graph.invalidate()
		destination = get_global_mouse_position()
		path = Graph.Pathfinder.get_shortest_path(Graph, global_position, destination);
		pathAttentionIndex = 0;
		if(path!=null):
			Line.points = path;
		if MOVE_TYPE == DIRECT:
			MOVE_TYPE = NAVIGATION;

## Main Move function
func MoveState(delta):
	var input_vector = Vector2.ZERO;

	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left");
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up");
	input_vector = input_vector.normalized();
		
	if MOVE_TYPE == NAVIGATION:
		if(path != null):
			if path.size() == 0 || pathAttentionIndex >= path.size():
				MOVE_TYPE = DIRECT
			else:
				var VectorTo = path[pathAttentionIndex] - global_position;
				input_vector = VectorTo.normalized();
				
				if path.size() > pathAttentionIndex + 1:
					var intersectInfo = Graph.intersectRay(global_position, path[pathAttentionIndex+1]);
					var canSeeDest = intersectInfo.empty();
					if(canSeeDest):
						pathAttentionIndex += 1;
				else:
					if(VectorTo.length() < max_speed * delta):
						pathAttentionIndex+=1;
			
	if(input_vector != Vector2.ZERO):
		rollVector = input_vector;
		swordHitBox.knockBackVector = input_vector;
		velocity = velocity.move_toward(input_vector*max_speed, acceleration);
		velocity = velocity.clamped(max_speed);
		animationTree.set("parameters/Idle/blend_position", input_vector);
		animationTree.set("parameters/Run/blend_position", input_vector);
		animationTree.set("parameters/Attack/blend_position", input_vector);		
		animationTree.set("parameters/Roll/blend_position", input_vector);
		animationState.travel("Run");
	else:
		animationState.travel("Idle");
		velocity = velocity.move_toward(Vector2.ZERO, acceleration);
	
	Move(input_vector);
	if Input.is_action_just_pressed("attack"):
		state = ATTACK;
	if Input.is_action_just_pressed("roll"):
		state = ROLL;
		
		

### Exposed functions for animation and other state changes
### Exposed functions for animation and other state changes
func Move(movementVector):
	velocity = move_and_slide(velocity);


func RollState(delta) :
	velocity = rollVector * max_speed * 1.5;
	animationState.travel("Roll");
	Move(velocity);

func AttackState(delta):
	velocity = Vector2.ZERO;
	animationState.travel("Attack");
	
func AttackEnd():
	state = MOVE;
	
func RollEnd():
	state = MOVE;
### Exposed functions for animation and other state changes
### Exposed functions for animation and other state changes
	

### General Health Interactions
### General Health Interactions
func setInvulnerable(tf):
	invulnerable = tf;
func _on_HurtBox_area_entered(area):
	if invulnerable:
		pass;
	else:
		effectsPlayer.play("Hurt");
		HealthManager.hurt(1);
func _on_Health_no_health():
	get_tree().reload_current_scene();
### General Health Interactions
### General Health Interactions
