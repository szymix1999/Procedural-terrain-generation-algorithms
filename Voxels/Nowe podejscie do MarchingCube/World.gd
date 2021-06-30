extends Spatial


const chunk_size = Vector3(16, 32, 16)

var noise
var noise_terrain
var chunks = {}
var unready_chunks = {}
var thread



func _ready():
#	VisualServer.set_debug_generate_wireframes(true)
#	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME if true else Viewport.DEBUG_DRAW_DISABLED
	randomize()
	
	noise = OpenSimplexNoise.new()
	noise.seed = 45
	noise.period = 16
	noise.octaves = 2
	
	noise_terrain = OpenSimplexNoise.new()
	noise_terrain.seed = 45
	noise_terrain.period = 16
	noise_terrain.octaves = 8
	
	thread = Thread.new()


func add_chunk(x,z):
	var key = Vector2(x,z)
	if chunks.has(key) or unready_chunks.has(key):
		return

	if not thread.is_active():
		thread.start(self, "load_chunk", [x,z,thread], 0)
		unready_chunks[key] = 1
		
func load_chunk(arr):
	var thread = arr[2]
	var x = arr[0]
	var z = arr[1]
	var chunk = NowePodejscie.new(noise, noise_terrain, Vector3(x * chunk_size.x, 0, z * chunk_size.z), chunk_size)
	call_deferred("load_done", chunk, thread)

func load_done(chunk, thread):
	thread.wait_to_finish()
	add_child(chunk)
	var key  = Vector2(chunk.position.x / chunk_size.x, chunk.position.z / chunk_size.z)
	chunks[key] = chunk
	unready_chunks.erase(key)
	
	
func get_chunk(x ,z):
	var key = Vector2(x,z)
	if chunks.has(key):
		return chunks.get(key)
	return null
	
func _process(delta):
	update_chunks2()

func update_chunks2():
	for x in range(0,8):
		for z in range(0, 8):
			add_chunk(x, z)
		
