extends KinematicBody2D

### Navigation
export(NodePath) var NavigationTiles = null;
onready var _nav: Navigation2D = get_node(NavigationTiles);
onready var destination = global_position;
var path = null;

var invulnerable = false;

const max_speed = 100;
const acceleration = 20;

var velocity = Vector2.ZERO;
var state = MOVE;
var rollVector = Vector2.DOWN;

onready var swordHitBox = $SwordRoot/HitBox

onready var effectsPlayer = $SpriteEffectAnimations
onready var animationTree = $AnimationTree
onready var HealthManager = $Health;
onready var Line = $Line2D;
onready var animationState = animationTree.get("parameters/playback");

enum {
	MOVE,
	ROLL,
	ATTACK,
}

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
		destination = get_global_mouse_position()
		print(destination);
		print(global_position)
			
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


func MoveState(delta):
	
	var input_vector = Vector2.ZERO;
	if global_position.distance_to(destination) > 1:
		var pathToDestination = _nav.get_simple_path(global_position, destination);
		if(pathToDestination.size()>0):
			input_vector = (pathToDestination[1] - global_position).normalized();
			Line.points = [];
			for i in range(pathToDestination.size()):
				Line.set_point_position(i, pathToDestination[i] - global_position);

#	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left");
#	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up");
#	input_vector = input_vector.normalized();
	
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
		velocity = velocity.move_toward(Vector2.ZERO, acceleration/2);
		animationState.travel("Idle");
	
	Move(velocity);
	if Input.is_action_just_pressed("attack"):
		state = ATTACK;
	if Input.is_action_just_pressed("roll"):
		state = ROLL;

func _on_HurtBox_area_entered(area):
	if invulnerable:
		pass;
	else:
		effectsPlayer.play("Hurt");
		HealthManager.hurt(1);
	
func setInvulnerable(tf):
	invulnerable = tf;

func _on_Health_no_health():
	get_tree().reload_current_scene();
