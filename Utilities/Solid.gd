extends StaticBody2D

onready var cutout = $CollisionPolygon2D;
onready var mesh = get_tree().get_nodes_in_group("NavigationMesh")[0] as NavigationPolygonInstance;


func _ready():
	# The Existing navigation mesh shape
	var currentPolygon = mesh.get_navigation_polygon();
	
	# The cutout taken from a local collision polygon
	var cutoutPolygon = cutout.get_polygon();
	var cutoutTransform = cutout.get_global_transform();
	
	# The inverted transform of the mesh projects the cutouts transform into mesh-coordinates
	var finalTransform = mesh.transform.inverse() * cutoutTransform;
	
	# Map all vertexes with xform? what is xform?
	var transformedCuttoutPolygon = PoolVector2Array();
	for vertex in cutoutPolygon:
		transformedCuttoutPolygon.append(finalTransform.xform(vertex))
		
	# Inject new shape into existing navmesh.
	currentPolygon.add_outline(transformedCuttoutPolygon);
	currentPolygon.make_polygons_from_outlines()
	mesh.set_navigation_polygon(currentPolygon);
	
	# Cycle the node to hack the mesh into updating its Navigation2D watchers
	mesh.enabled = false;
	mesh.enabled = true;
