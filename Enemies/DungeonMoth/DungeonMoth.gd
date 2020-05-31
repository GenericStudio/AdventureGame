extends KinematicBody2D

# Animations
const _batDeath = preload("DeathEffect.tscn");
const _batHit = preload("HitEffect.tscn");
export(NodePath) var NavigationTiles = null;
onready var _nav: Navigation2D = get_node(NavigationTiles);

# Movement
const max_speed = 50;
const acceleration = 100;
var velocity = Vector2.ZERO;
var knockBack = Vector2.ZERO;
var personalSpaceVector = Vector2.ZERO;
onready var startPosition = global_position;

#Components
onready var Stats = $Stats;
onready var sprite = $Sprite;
onready var PlayerChaseZone = $PlayerChaseZone;
onready var PersonalSpace = $PersonalSpace;
onready var Line = $Line2D;
#AI
var state = IDLE;
enum {
	IDLE,
	WANDER,
	CHASE
}
	

func _physics_process(delta):
	knockBack = knockBack.move_toward(Vector2.ZERO, acceleration*delta);
	


	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration*delta);
			personalSpaceVector =  personalSpaceVector.move_toward(Vector2.ZERO, acceleration*delta);
		WANDER:
			var pathToHome = _nav.get_simple_path(global_position, startPosition);
			if(pathToHome.size()>0):
				var direction = (pathToHome[1] - global_position).normalized();
				velocity = velocity.move_toward(direction * max_speed, acceleration * delta);
			sprite.flip_h = velocity.x<0;
			if startPosition.distance_to(global_position) < 3:
				state=IDLE;
			
		
		CHASE:
			var pathToPlayer = _nav.get_simple_path(global_position, PlayerChaseZone.player.global_position);
			if(pathToPlayer.size()>0):
				var direction = ( pathToPlayer[1]-global_position).normalized();
				velocity = velocity.move_toward(direction * max_speed, acceleration * delta);
			sprite.flip_h = velocity.x<0;
			if PersonalSpace.is_colliding():
				personalSpaceVector = personalSpaceVector.move_toward(PersonalSpace.force_vector()*max_speed, acceleration*delta/2);
			else:
				personalSpaceVector =  personalSpaceVector.move_toward(Vector2.ZERO, acceleration*delta);
		
		

	move_and_slide(velocity + knockBack + personalSpaceVector);


func _on_HurtBox_area_entered(area):
	var batHit = _batHit.instance();
	get_parent().add_child(batHit);
	batHit.global_position = global_position;
	Stats.health -= area.damage;
	knockBack = area.knockBackVector * max_speed * 3;

func _on_Stats_no_health():
	var batDeath = _batDeath.instance();
	get_parent().add_child(batDeath);
	batDeath.global_position = global_position;
	queue_free();



func _on_PlayerChaseZone_player_seen():
	state = CHASE;


func _on_PlayerChaseZone_player_lost():
	state = WANDER;
