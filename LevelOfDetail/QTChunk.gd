extends Spatial

var MAX_LEVEL = 7
var QUALITY
var LAST_VERTEX
onready var CHUNK = load("res://QTChunk.tscn")

var size
var position : Vector3
var noise : OpenSimplexNoise
var is_leaf
var level

var avg_height = 0
var which_child
var parent
var mux_height = 111

var data_tool : MeshDataTool


var children = []

var material = preload("res://ground.material")

func init(size, position, noise, level, parent, which_child):
	QUALITY = 3
	LAST_VERTEX = (QUALITY+2)*(QUALITY+2)
	self.size = size
	self.position = position
	self.noise = noise
	self.level = level
	self.is_leaf = true
	self.which_child = which_child
	self.parent = parent
	
	self.translation = position
	$Mesh.mesh = create_mesh()
		


func _process(delta):
	var player_pos = get_parent().find_node("Player").translation
	var distance = player_pos.distance_to(Vector3(self.position.x, avg_height, self.position.z))
	
	for i in range(1,MAX_LEVEL):
		if(distance<(MAX_LEVEL-i)*size && level<i):
			subdivide()
			
	for i in range(1,MAX_LEVEL):
		if(distance>=(MAX_LEVEL-i)*size && level>=i):
			unsubdivide()
		

	if which_child == 0 || which_child == 1:
		var d = polnoc()
		if d!=null && d.level < level:
			divide_edge("left")
		elif d!=null:
			undivide_edge("left")

	if which_child == 2 || which_child == 3:
		var d = poludnie()
		if d!=null && d.level < level:
			divide_edge("right")
		elif d!=null:
			undivide_edge("right")

	if which_child == 0 || which_child == 2:
		var d = wschod()
		if d!=null && d.level < level:
			divide_edge("down")
		elif d!=null:
			undivide_edge("down")

	if which_child == 1 || which_child == 3:
		var d = zachod()
		if d!=null && d.level < level:
			divide_edge("up")
		elif d!=null:
			undivide_edge("up")


func create_mesh():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size, size)
	plane_mesh.subdivide_depth = QUALITY
	plane_mesh.subdivide_width = QUALITY

	data_tool = MeshDataTool.new()
	var mesh = ArrayMesh.new()
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_mesh.get_mesh_arrays())
	data_tool.create_from_surface(mesh,0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		var val = noise.get_noise_2d(vertex.x + position.x, vertex.z + position.z)
		vertex.y = val * mux_height
		avg_height+=vertex.y
		data_tool.set_vertex(i,vertex)
		
	avg_height/=data_tool.get_vertex_count()
	mesh.surface_remove(0) 
	data_tool.commit_to_surface(mesh)

	mesh.surface_set_material(0,material)
	
	return mesh

#-------top------
#|				|
#l				r
#e				i
#f				g
#t				h
#|				t
#-------back-----

func divide_edge(dir):
	match dir:
		"left" : divide_left_edge(data_tool, true)
		"right" : divide_right_edge(data_tool, true)
		"up" : divide_top_edge(data_tool, true)
		"down" : divide_bottom_edge(data_tool, true)
		
	var mesh = Mesh.new()
	data_tool.commit_to_surface(mesh)
	
	mesh.surface_set_material(0,material)

	$Mesh.mesh = mesh
	
func undivide_edge(dir):
	match dir:
		"left" : divide_left_edge(data_tool, false)
		"right" : divide_right_edge(data_tool, false)
		"up" : divide_top_edge(data_tool, false)
		"down" : divide_bottom_edge(data_tool, false)
		
	var mesh = Mesh.new()
	data_tool.commit_to_surface(mesh)
	
	mesh.surface_set_material(0,material)

	$Mesh.mesh = mesh

func polnoc():
	if parent == null or parent.children.empty():
		return null
		
	if parent.children[2] == self:
		return parent.children[0]
	if parent.children[3] == self:
		return parent.children[1]
		
	var node = parent.polnoc()
	if node == null or node.is_leaf:
		return node
	
	if parent.children[0] == self:
		return node.children[2]
	else:
		return node.children[3]
		
func poludnie():
	if parent == null or parent.children.empty():
		return null
		
	if parent.children[0] == self:
		return parent.children[2]
	if parent.children[1] == self:
		return parent.children[3]
		
	var node = parent.poludnie()
	if node == null or node.is_leaf:
		return node
	
	if parent.children[2] == self:
		return node.children[0]
	else:
		return node.children[1]
		
func wschod():
	if parent == null or parent.children.empty():
		return null
		
	if parent.children[1] == self:
		return parent.children[0]
	if parent.children[3] == self:
		return parent.children[2]
		
	var node = parent.wschod()
	if node == null or node.is_leaf:
		return node
	
	if parent.children[0] == self:
		return node.children[1]
	else:
		return node.children[3]
		
func zachod():
	if parent == null or parent.children.empty():
		return null
		
	if parent.children[0] == self:
		return parent.children[1]
	if parent.children[2] == self:
		return parent.children[3]
		
	var node = parent.zachod()
	if node == null or node.is_leaf:
		return node
	
	if parent.children[1] == self:
		return node.children[0]
	else:
		return node.children[2]


func divide_top_edge(mdt : MeshDataTool, b):
	for i in range(0,LAST_VERTEX,QUALITY+2):
		if i%2:
			var v1 = mdt.get_vertex(i+(QUALITY+2))
			var v2 = mdt.get_vertex(i-(QUALITY+2))
			var vertex = mdt.get_vertex(i)
			if b:
				vertex.y = lerp( v1.y, v2.y, 0.5)
			else:
				var val = noise.get_noise_2d(vertex.x + position.x, vertex.z + position.z)
				vertex.y = val * mux_height
			mdt.set_vertex(i,vertex)
			
func divide_bottom_edge(mdt : MeshDataTool, b):
	for i in range(QUALITY+2-1,LAST_VERTEX,QUALITY+2):
		if i%2:
			var v1 = mdt.get_vertex(i+(QUALITY+2))
			var v2 = mdt.get_vertex(i-(QUALITY+2))
			var vertex = mdt.get_vertex(i)
			if b:
				vertex.y = lerp( v1.y, v2.y, 0.5)
				#vertex.y = 100
			else:
				var val = noise.get_noise_2d(vertex.x + position.x, vertex.z + position.z)
				vertex.y = val * mux_height
			mdt.set_vertex(i,vertex)
			
func divide_left_edge(mdt : MeshDataTool, b):
	for i in range(0, QUALITY+2, 1):
		if i%2:
			var v1 = mdt.get_vertex(i+1)
			var v2 = mdt.get_vertex(i-1)
			var vertex = mdt.get_vertex(i)
			if b:
				vertex.y = lerp( v1.y, v2.y, 0.5)
			else:
				var val = noise.get_noise_2d(vertex.x + position.x, vertex.z + position.z)
				vertex.y = val * mux_height
			mdt.set_vertex(i,vertex)
	
			
func divide_right_edge(mdt : MeshDataTool, b):
	for i in range(LAST_VERTEX-(QUALITY+2), LAST_VERTEX, 1):
		if i%2:
			var v1 = mdt.get_vertex(i+1)
			var v2 = mdt.get_vertex(i-1)
			var vertex = mdt.get_vertex(i)
			if b:
				vertex.y = lerp( v1.y, v2.y, 0.5)
			else:
				var val = noise.get_noise_2d(vertex.x + position.x, vertex.z + position.z)
				vertex.y = val * mux_height
			mdt.set_vertex(i,vertex)

func subdivide():
	if level < MAX_LEVEL and is_leaf:
		is_leaf = false
		$Mesh.visible = false
		var new_size = size/4

		for i in range(4):
			var child = CHUNK.instance()
			var position
			match(i):
				0: position = Vector3(self.position.x - new_size, self.position.y, self.position.z + new_size)
				1: position = Vector3(self.position.x + new_size, self.position.y, self.position.z + new_size)
				2: position = Vector3(self.position.x - new_size, self.position.y, self.position.z - new_size)
				3: position = Vector3(self.position.x + new_size, self.position.y, self.position.z - new_size)
			child.init(new_size*2, position, noise, level+1, self, i)
			children.push_back(child)
			get_parent().add_child(child)


func unsubdivide():
	if children.size()>0:
		is_leaf = true
		$Mesh.visible=true
		for c in children:
			c.delete()
		children.clear()
	
func delete():
	self.queue_free()
	
