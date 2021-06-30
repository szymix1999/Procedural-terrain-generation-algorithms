extends Spatial

onready var CHUNK = preload("res://QTChunk.tscn")
var noise : OpenSimplexNoise
const chunk_size = 2048

func _ready():
	VisualServer.set_debug_generate_wireframes(true)
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME if true else Viewport.DEBUG_DRAW_DISABLED
	
	noise = OpenSimplexNoise.new()
	noise.seed = 123
	noise.period = 543
	noise.octaves = 6
	
	var chunk = CHUNK.instance()
	chunk.init(chunk_size, Vector3(0, 0, 0), noise, 0, null, -1)
	add_child(chunk)
