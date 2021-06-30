extends Spatial

const size = Vector3(64, 64, 64)
var voxels = []

func _ready():
#	VisualServer.set_debug_generate_wireframes(true)
#	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME if true else Viewport.DEBUG_DRAW_DISABLED
	set_arr()
	set_terrain()
	
	
	var r1 = Robak.new(Vector3(32,32,32), 88)
	r1.eat(voxels, size)
	
	var r2 = Robak.new(Vector3(11,22,11), 88)
	r2.eat(voxels, size)
	
	var r3 = Robak.new(Vector3(22,22,22), 88)
	r3.eat(voxels, size)
	
	var chunk = NowePodejscie.new(size, voxels)
	add_child(chunk)
	

func set_arr():
	for x in range(0, size.x):
		var row = [];
		for y in range(0, size.y):
			var column = [];
			for z in range(0,size.z):
				column.append(false);
			row.append(column);
		voxels.append(row);

func set_terrain():
	for x in range(0, size.x):
		for y in range(0, size.y):
			for z in range(0,size.z):
				voxels[x][y][z] = 1

