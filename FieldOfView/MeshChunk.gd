extends Spatial
class_name MeshChunk

var mesh_instance
var noise
var x
var z
var chunk_size
var should_remove = false


func _init(noise, x, z, chunk_size):
	self.noise = noise
	self.x = x
	self.z = z
	self.chunk_size = chunk_size
	
func _ready():
	generate_chunk()

func generate_chunk():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size * 0.2
	plane_mesh.subdivide_width = chunk_size * 0.2
	
	var surface_tool = SurfaceTool.new()
	var data_tool = MeshDataTool.new()
	surface_tool.create_from(plane_mesh,0)
	var arr_plane = surface_tool.commit()
	var error = data_tool.create_from_surface(arr_plane,0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = fbm(vertex) * 120
		data_tool.set_vertex(i,vertex)
		
	for s in range(arr_plane.get_surface_count()):
		arr_plane.surface_remove(s)
	
	data_tool.commit_to_surface(arr_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(arr_plane,0)
	surface_tool.generate_normals()

	mesh_instance = MeshInstance.new()
	var m = surface_tool.commit()
	mesh_instance.mesh = m
	mesh_instance.material_override = preload("res://Material/terrain.material")
	add_child(mesh_instance)
	
func fbm(vec3):
	return range_lerp(noise.get_noise_2d(vec3.x+x, vec3.z+z),-1,1,0,1)
