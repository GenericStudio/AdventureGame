extends Node2D

# pred (predecessor) maps destination vertex index 
# to the previous vertex index along shortest path (so far)
var pred = {}
# cost tracks the shortest cost to each vertex (key is vertex index, again)
var cost = {}
var last_start
var last_dest
var _frontier

enum SearchMode {
	DijkstrasAlgorithm,
	A_Star,
}

export (SearchMode) var search_mode = SearchMode.A_Star
	
export (bool) var track_explored_edges = false
var explored_edges = []

func _ready():
	_frontier = preload("MinHeap.gd").new()

func clear_path():
	_frontier.clear()
	pred = {}
	cost = {}
	explored_edges = []
	
func heuristic(from_pos : Vector2, to_pos : Vector2):
	return (from_pos - to_pos).length()
			
func get_shortest_path(graph, from_pos : Vector2, to_pos : Vector2):
	clear_path()
	var from_idx = graph.find_closest_vertex_idx(from_pos)
	var to_idx = graph.find_closest_vertex_idx(to_pos)
	if from_idx == -1 or to_idx == -1:
		return null
	last_start = graph.vertices[from_idx]
	last_dest = graph.vertices[to_idx]
	if from_idx == -1 || to_idx == -1:
		print("those points aren't in the graph area")
		return null
	var n = len(graph.vertices)
	
	cost[from_idx] = 0
	pred[from_idx] = null
	# add all the vertices to the min heap
	_frontier.insert_with_priority(from_idx, 0)
		
	# until min-heap is empty, pop the min [cost vertex to reach], and explore it's outgoing edges
	while not _frontier.is_empty():
		var curr_idx = _frontier.pop_min()
		# terminate here if found the goal
		if curr_idx == to_idx:
			break
		for out_edge in graph.get_out_edges(curr_idx):
			var dest_idx = out_edge[0]
			if track_explored_edges:
				explored_edges.append([curr_idx, dest_idx])
			var w = out_edge[1]
			# relax, mensch
			var prev_cost = cost[dest_idx] if cost.has(dest_idx) else INF
			var total_w = cost[curr_idx] + w
			# var prev_cost = cost[dest_idx] if cost.has(dest_idx) else INF
			if total_w < prev_cost:
				# new shortest path to reach dest
				cost[dest_idx] = total_w
				pred[dest_idx] = curr_idx
				# update_priority will insert the value if it does not exist
				var heap_idx = _frontier.find_index(dest_idx)
				var prio = total_w
				if search_mode == SearchMode.A_Star:
					prio += heuristic(graph.vertices[dest_idx], to_pos)
				if heap_idx > -1:
					_frontier.update_priority(heap_idx, prio)
				else:
					_frontier.insert_with_priority(dest_idx, prio)
				
	if not pred.has(to_idx):
		# no path :(
		print ("no path found!")
		return null
	# assembly the path (in reverse)
	var curr_idx = to_idx
	var offset = global_position
	var path = [
		to_pos,
		offset + graph.vertices[curr_idx],
	]
	
	while pred[curr_idx] != null:
		curr_idx = pred[curr_idx]
		var global_point = offset + graph.vertices[curr_idx]
		path.push_back(global_point)
		
	path.append(from_pos)
	path.invert()
	
	if path.size()>2:

		var index = 0;
		while index < path.size():
			print(path);
			var point = path[index];
			if(path.size() > index+2):
				var intersectInfo = graph.intersectRay(point, path[index+2]);
				if(intersectInfo.empty()):
					path.remove(index+1);
				else:
					index +=1;
			else:
				index+=1;
					
				
	return path
	
