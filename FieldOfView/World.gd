extends Spatial


const chunk_size = 128
const chunk_amount = 8

var noise
var chunks = {}
var unready_chunks = {}
var thread
var remove_thread

var look_position = 'z'

func _ready():
#	VisualServer.set_debug_generate_wireframes(true)
#	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME if true else Viewport.DEBUG_DRAW_DISABLED
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = 1234
	noise.octaves = 6
	noise.period = 400
	
	thread = Thread.new()
	remove_thread = Thread.new()


func add_chunk(x,z):
	var key = Vector2(x,z)
	if chunks.has(key) or unready_chunks.has(key):
		if chunks.has(key):
			chunks[key].should_remove = false
		return

	if not thread.is_active():
		thread.start(self, "load_chunk", [x,z,thread],0)
		unready_chunks[key] = 1
		
func load_chunk(arr):
	var thread = arr[2]
	var x = arr[0]
	var z = arr[1]
	
	var chunk = MeshChunk.new(noise, x*chunk_size, z*chunk_size, chunk_size)
	chunk.translation = Vector3(x*chunk_size, 0, z*chunk_size)
	call_deferred("load_done", chunk, thread)

func load_done(chunk, thread):
	thread.wait_to_finish()
	add_child(chunk)
	var key  = Vector2(chunk.x / chunk_size, chunk.z / chunk_size)
	chunks[key] = chunk
	unready_chunks.erase(key)
	
	
func get_chunk(x ,z):
	var key = Vector2(x,z)
	if chunks.has(key):
		return chunks.get(key)
	return null
	
func _process(delta):
	update_chunks2()
	reset_chunks()

func update_chunks2():
	var player_pos = $Player.translation
	var px = int(player_pos.x) / chunk_size
	var pz = int(player_pos.z) / chunk_size
	
	var x
	var z
	
	for k in chunks:
		chunks[k].should_remove = true


	if(look_position == "z"):
		for i in range(chunk_amount):
			for j in range(i+4):
				for k in [-1,1]:
					x = px+j*k
					z = pz+i
					add_chunk(x,z)
					
	
	if(look_position == "x"):
		for i in range(chunk_amount):
			for j in range(i+4):
				for k in [-1,1]:
					x = px+i
					z = pz+j*k
					
					add_chunk(x,z)
	
						
	if(look_position == "-z"):
		for i in range(chunk_amount):
			for j in range(i+4):
				for k in [-1,1]:
					x = px-j*k
					z = pz-i
					
					add_chunk(x,z)
	
	if(look_position == "-x"):
		for i in range(chunk_amount):
			for j in range(i+4):
				for k in [-1,1]:
					x = px-i
					z = pz-j*k
					
					add_chunk(x,z)
						
	if(look_position == "-x,z"):
		for i in range(chunk_amount):
			var val = i+1
			for j in range(val,0,-1):
					x = px-j
					z = pz+(val-j)
					
					add_chunk(x,z)
						
	if(look_position == "x,z"):
		for i in range(chunk_amount):
			var val = i+1
			for j in range(val,0,-1):
					x = px+j
					z = pz+(val-j)
					
					add_chunk(x,z)
						
	if(look_position == "-x,-z"):
		for i in range(chunk_amount):
			var val = i+1
			for j in range(val,0,-1):
					x = px-(val-j)
					z = pz-j
					
					add_chunk(x,z)
						
	if(look_position == "x,-z"):
		for i in range(chunk_amount):
			var val = i+1
			for j in range(val,0,-1):
					x = px+(val-j)
					z = pz-j
					
					add_chunk(x,z)

func reset_chunks():
	var player_pos = $Player.translation
	
	var px = int(player_pos.x) / chunk_size
	var pz = int(player_pos.z) / chunk_size
	
	for k in chunks:
		if(k.x > px+chunk_amount || k.x < px-chunk_amount || k.y > pz+chunk_amount || k.y < pz-chunk_amount):
			if chunks[k].should_remove:
				chunks[k].queue_free()
				chunks.erase(k)

func _on_Player_change_position(position):
	look_position = position
	print(position)
