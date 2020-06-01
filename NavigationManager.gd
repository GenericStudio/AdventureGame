extends Node2D

var Holes = [];

onready var mesh = $NavigationMesh;

func _ready():
	yield(get_tree(), "idle_frame") 
	cutHoles();


func cutHoles():
	var currentPolygon = mesh.get_navigation_polygon();
	# currentPolygon.clear_outlines();
	# currentPolygon.clear_polygons();
	for cutout in Holes:
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
	mesh.enabled = false;
	mesh.enabled = true;
	# Cycle the node to hack the mesh into updating its Navigation2D watchers



