extends Object
# MinHeap
# always keeps the minimum value at the root of the "tree" for easy access

# _arr is an array that represents the heap, so blurr thine eyes and think it as a tree
# every tree node can have a left and right child
# the zeroth element is the root of the tree
var _arr : Array

const NO_PARENT = -1
# "key" constants
const K_PRIORITY = "priority"
const K_VALUE = "value"

# a heap "node" is a Dictionary with two entries, value and priority
# example min-heap with 3 "nodes" represented by _arr:
"""
_arr = [{
			value: Vector2(10, 20)
			priority: 1
		},
		{
			value: Vector2(55, 10)
			priority: 5
		},
		{
			value: Vector2(6, 2)
			priority: 3
		}]
"""
func new_node(value, priority):
	return {
		K_VALUE : value,
		K_PRIORITY : priority,
	}

func is_empty():
	return len(_arr) == 0

func get_size():
	return len(_arr)

func clear():
	_arr = []

func get_parent_idx(idx : int):
	if idx == 0:
		return NO_PARENT
	return int(floor((idx - 1)/2))

# index of left child of _arr[idx]
func get_left_idx(idx : int):
	return int(idx * 2 + 1)

# index of right child of _arr[idx]
func get_right_idx(idx : int):
	return int((idx + 1) * 2)

# insert adds a node to the end of _arr then calls swim_up	
func insert_with_priority(obj, priority):
	var node = new_node(obj, priority)
	_arr.append(node)
	swim_up(len(_arr)-1)

func priority_at(idx : int):
	return _arr[idx][K_PRIORITY]
	
func value_at(idx : int):
	return _arr[idx][K_VALUE]

func _swap_nodes(i : int, j : int):
	var t = _arr[i]
	_arr[i] = _arr[j]
	_arr[j] = t

# check if parent has higher priority value than idx
# if so, swap and repeat up the chain
func swim_up(idx : int):
	if idx == 0:
		return
	var p = get_parent_idx(idx)
	if priority_at(idx) < priority_at(p):
		_swap_nodes(idx, p)
		swim_up(p)

func pop_min():
	var min_node = pop_min_node()
	return min_node[K_VALUE]
	
func pop_min_node():
	if len(_arr) == 0:
		return null
	var m = _arr[0]
	var last_idx = len(_arr)-1
	_arr[0] = _arr[last_idx]
	_arr.remove(last_idx)
	min_heapify(0)
	return m

func find_index(node_value):
	for idx in range(len(_arr)):
		var test_val = value_at(idx)
		if node_value == test_val:
			return idx
	return -1

# update_priority could use some work
# calling swim_up and min_heap should catch all cases
# ... but it's not efficient
func update_priority(idx : int, new_priority):
	_arr[idx][K_PRIORITY] = new_priority
	swim_up(idx)
	min_heapify(idx)
	
# min_heapify: operates on the sub-tree that has _arr[idx] as it's root
# swaps the node at idx downward until the sub-tree is again a min-heap
# assumes that the left and right sub-trees of _arr[idx] are already valid min-heaps
func min_heapify(idx : int):
	var smaller_idx = idx
	var L = get_left_idx(idx)
	var R = get_right_idx(idx)
	if L < len(_arr) and priority_at(L) < priority_at(smaller_idx):
		smaller_idx = L
	if R < len(_arr) and priority_at(R) < priority_at(smaller_idx):
		smaller_idx = R
	if smaller_idx != idx:
		_swap_nodes(idx, smaller_idx)
		min_heapify(smaller_idx)
