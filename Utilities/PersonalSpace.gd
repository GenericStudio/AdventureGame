extends Area2D


var areas = null;

func is_colliding():
	areas = get_overlapping_bodies();
	return areas.size() > 0;
	
func force_vector():
	return (global_position - areas[0].global_position).normalized();
