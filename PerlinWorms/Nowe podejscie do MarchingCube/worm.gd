extends Node
class_name Robak


var current_length
var length
var start_position : Vector3
var current_position : Vector3

var direction_noise : OpenSimplexNoise
var radius_noise : OpenSimplexNoise
var terrain_noise : OpenSimplexNoise

func _init(start_position: Vector3, length: int):
	randomize()
	direction_noise = OpenSimplexNoise.new()
	direction_noise.seed = randi()
	direction_noise.period = int(rand_range(4, 32))
	
	radius_noise = OpenSimplexNoise.new()
	radius_noise.seed = randi()
	radius_noise.period = int(rand_range(4, 32))
	
	
	terrain_noise = OpenSimplexNoise.new()
	terrain_noise.seed = randi()
	terrain_noise.period = int(rand_range(12, 32))
	terrain_noise.octaves = 5
	
	self.start_position = start_position
	self.current_position = start_position
	self.length = length
	self.current_length = 0


func make_arr_terrain(radius, voxels, size):
	for x in range(-radius/2, radius/2):
		for y in range(-radius/2, radius/2):
			for z in range(-radius/2, radius/2):
				var xx = current_position.x + x
				var yy = current_position.y + y
				var zz = current_position.z + z
				
				if is_outside(xx,yy,zz,size):
					continue
				
				var gradient = range_lerp(current_position.distance_to(Vector3(xx,yy,zz)), 0, radius, -1, 1)
				voxels[xx][yy][zz] += gradient + range_lerp(terrain_noise.get_noise_3d(xx, yy, zz), -1, 1, -1, 1)

func is_outside(xx,yy,zz,size):
	if xx >= size.x or xx < 0:
		return true
	if yy >= size.y or yy < 0:
		return true
	if zz >= size.z or zz < 0 :
		return true
	return false

func get_direction():
	var dir = range_lerp(direction_noise.get_noise_3d(current_position.x, current_position.y, current_position.z), -1, 1, 0, 6)
	match int(dir):
		0: return Vector3(1,1,0)
		1: return Vector3(0,1,1)
		2: return Vector3(1,0,1)
		3: return Vector3(-1,-1,0)
		4: return Vector3(0,-1,-1)
		5: return Vector3(-1,0,-1)
		
func get_radius():
	return range_lerp(radius_noise.get_noise_3d(current_position.x, current_position.y, current_position.z),-1, 1, 4, 32)

func eat(voxels, size):
	while current_length < length:
		current_position += get_direction()
		current_length+=1
		var radius = get_radius()
		make_arr_terrain(radius, voxels, size)
