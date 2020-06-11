
extends Node2D

signal graph_built

const DIAG_WEIGHT = 1.414

export (int) var grid_step_px = 16
export (int) var grid_offset_px = 8
export (Rect2) var search_rect 
export (bool) var allow_diagonal = true
export (Color) var edge_color = Color(1, 1, 0, 0.5)
export (float) var edge_width = 1.0
export (bool) var draw_vertices = true
export (Color) var vertex_color = Color.green
export (float) var vertex_radius = .5
export (int) var collisisionMask = 1;

export (bool) var centered = true;

# vertices is an array of Vector2
var vertices : Array = []
var _bad_vertices : Dictionary = {}
var _adjacency : Dictionary = {}
var column_count : int
var row_count : int

onready var Pathfinder = $Pathfinder;
var offset = Vector2.ZERO;
# Called when the node enters the scene tree for the first time.
func _ready():
	column_count = int(floor(search_rect.size.x / grid_step_px));
	row_count = int(floor(search_rect.size.y / grid_step_px));
	offset =  Vector2(-search_rect.size.x/2, -search_rect.size.y/2) if centered else  Vector2(grid_offset_px, grid_offset_px)
	build_graph()

		
func invalidate():
	global_position = get_parent().get_parent().global_position
	global_position = Vector2(stepify(global_position.x, grid_step_px)+ grid_offset_px, stepify(global_position.y, grid_step_px)+grid_offset_px);
	build_graph()

func build_graph():
	clear_graph()
	add_vertices()
	update_bad_vertices()
	add_edges()
	emit_signal("graph_built")
	update()
	_draw()

func _draw():
	#for edge in explored_edges:
	#	draw_line(vertices[edge[0]], vertices[edge[1]], Color.purple, 3)
	for i in range(len(vertices)):
		for e in _adjacency[i]:
			draw_line(vertices[i], vertices[e[0]], edge_color, edge_width)
	if draw_vertices:
		for i in range(len(vertices)):
			if not _bad_vertices.has(i):
				draw_circle(vertices[i], vertex_radius, vertex_color)

func clear_graph():
	vertices = []
	_adjacency = {}
		
func add_vertices():
	# add those vertices
	for x in range(column_count):
		for y in range(row_count):
			var vert = offset + Vector2(x, y) * grid_step_px
			vertices.append(vert)
			_adjacency[len(vertices)-1] = []
	print("the graph has %s vertices" % len(vertices))

func update_bad_vertices():
	var world = get_world_2d()
	var space = world.direct_space_state
	_bad_vertices = {}
	for i in range(len(vertices)):
		var vert = vertices[i]
		var world_pos = global_position + vert
		var collisions = space.intersect_point(world_pos, 1,[], collisisionMask)
		if len(collisions) > 0:
			_bad_vertices[i] = true


func intersectRay(from, to):
	var world = get_world_2d()
	var space = world.direct_space_state
	return space.intersect_ray(from, to,[], collisisionMask)
	
func try_add_edge(from_idx : int, to_idx : int, weight, also_add_reverse : bool = false):
	if _bad_vertices.has(from_idx) or _bad_vertices.has(to_idx):
		return false
	
	var w1 = global_position + vertices[from_idx]
	var w2 = global_position + vertices[to_idx]
	var intersect_info = intersectRay(w1, w2);
	if !intersect_info.empty():
#		_bad_vertices[from_idx]=true;
#		_bad_vertices[to_idx]=true;
		return false
	
	_adjacency[from_idx].append([to_idx, weight])
	if also_add_reverse:
		try_add_edge(to_idx, from_idx, weight, false)
	return true

func add_edges():
	# add those vertices
	for x in range(column_count):
		for y in range(row_count):
			var idx = int(x * row_count + y)
			if y < row_count-1:
				try_add_edge(idx, idx+1, 1, true)
			if x < column_count-1:
				try_add_edge(idx, idx+row_count, 1, true)
			if allow_diagonal and x < column_count-1 and y > 0:
				try_add_edge(idx, idx+row_count-1, DIAG_WEIGHT, true)
			if allow_diagonal and x < column_count-1 and y < row_count-1:
				try_add_edge(idx, idx+row_count+1, DIAG_WEIGHT, true)


# public way to get outgoing edges of a vertex
func get_out_edges(vertex_idx):
	return _adjacency[vertex_idx]

# find_closest_vertex_idx doesn't exactly return the "closest" vertex, 
# it returns the vertex to the upper left of the square grid cell that was clicked
# TODO make it better by incorporating grid_offset_px
func find_closest_vertex_idx(pos : Vector2):
	var _min = 100;
	var id = -1;
	for vertId in range(vertices.size()):
		var vert = vertices[vertId] as Vector2;
		var dist = pos.distance_to(global_position + vert);
		if dist < _min:
			_min =  dist;
			id = vertId;
	
	return id;
