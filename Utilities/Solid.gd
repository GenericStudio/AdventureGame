extends StaticBody2D

onready var cutout = $CollisionPolygon2D;
onready var mesh = get_tree().get_nodes_in_group("NavigationMesh")[0] as NavigationPolygonInstance;
onready var meshManager = mesh.get_parent().get_node("NavigationManager");
var transformedCuttoutPolygon = PoolVector2Array();
var holeId = null;
var secretVector = Vector2.ZERO;
func findOutline(outlines):
	for i in range(outlines.get_outline_count()):
		var inspect = outlines.get_outline(i);
		print(secretVector, inspect[1]);
		if(secretVector.distance_to(inspect[1]) < 1):
			return i;

		

func _ready():
	# The Existing navigation mesh shape
	var currentPolygon = mesh.get_navigation_polygon();
	
	# The cutout taken from a local collision polygon
	var cutoutPolygon = cutout.get_polygon();
	var cutoutTransform = cutout.get_global_transform();
	
	# The inverted transform of the mesh projects the cutouts transform into mesh-coordinates
	var finalTransform = mesh.transform.inverse() * cutoutTransform;
	
	# Map all vertexes with xform? what is xform?
	transformedCuttoutPolygon.append(finalTransform.xform(cutoutPolygon[0]))

	holeId = meshManager.holeCount;
	meshManager.holeCount +=1;
	print(holeId);
	secretVector = finalTransform.xform(Vector2(holeId, holeId));
	transformedCuttoutPolygon.append(secretVector)
	for vertex in cutoutPolygon:
		transformedCuttoutPolygon.append(finalTransform.xform(vertex))
		
	
	# Inject new shape into existing navmesh.
	currentPolygon.add_outline(transformedCuttoutPolygon);
	currentPolygon.make_polygons_from_outlines()
	mesh.set_navigation_polygon(currentPolygon);
	
	# Cycle the node to hack the mesh into updating its Navigation2D watchers
	mesh.enabled = false;
	mesh.enabled = true;
	holeId = currentPolygon.get_outline_count();


func _exit_tree():
		# The Existing navigation mesh shape
	var currentPolygon = mesh.get_navigation_polygon();
	
	var holeIdx = findOutline(currentPolygon);
	print("exiting ", holeIdx, " of ", currentPolygon.get_outline_count())
	# Inject new shape into existing navmesh.
	currentPolygon.remove_outline(holeIdx);
	currentPolygon.make_polygons_from_outlines()
	mesh.set_navigation_polygon(currentPolygon);
	
#	# Cycle the node to hack the mesh into updating its Navigation2D watchers
	mesh.enabled = false;
	mesh.enabled = true;
