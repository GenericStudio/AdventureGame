extends Node2D

export (Color) var path_color = Color.cyan
export (float) var path_width = 5

export (Color) var explored_color = Color.salmon
export (float) var explored_width = 3

export (int) var godude_count = 50
# path isn't allowed to update until this many seconds have passed
export (float) var path_update_delay = 0.05
var time_since_path_update = INF

onready var Graph = get_node('../');

var screen_size
var screen_mid_point


"""
you can make the graph update periodically, if you wish
var graph_update_rate = 2
var graph_timer = graph_update_rate
"""

func _ready():
	# Called when the node is added to the scene for the first time.
	screen_size = get_viewport_rect().size;
	screen_mid_point = screen_size * 0.5
	Graph.connect("graph_built", self, "try_find_path")


	

func _draw():
	draw_path()
	

func draw_path():
	for e in Graph.Pathfinder.explored_edges:
		draw_line(Graph.vertices[e[0]], Graph.vertices[e[1]], explored_color, explored_width)
	
		
	
func update_graph():
	Graph.invalidate()
