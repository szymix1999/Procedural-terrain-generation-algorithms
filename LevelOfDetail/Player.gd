extends KinematicBody

const GRAVITY = 26
var vel = Vector3()
var MAX_SPEED = 400
const JUMP_SPEED = 200
const ACCEL = 4

var dir = Vector3()

const DEACCEL= 4
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05
var m_direction = "-"

signal change_position(position)

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x

	if Input.is_action_pressed("movement_jump"):
		vel.y = JUMP_SPEED
		
	if Input.is_action_pressed("shift"):
		vel.y = -JUMP_SPEED
	
	if Input.is_action_pressed("speed"):
		MAX_SPEED = 1000

	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	vel.y = 0

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1 ))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
		
		var val  = self.rotation_degrees.y
		
		if(val<-155 || val>155) && m_direction!='z':
			m_direction='z'
		elif(val<-65 && val>-115) && m_direction!='x':
			m_direction='x'
		elif(val<25 && val>-25) && m_direction!='-z':
			m_direction='-z'
		elif(val>65 && val<115) && m_direction!='-x':
			m_direction='-x'
		elif(val>25 && val<65) && m_direction!='-x,-z':
			m_direction='-x,-z'
		elif(val>115 && val<155) && m_direction!='-x,z':
			m_direction='-x,z'
		elif(val<-25 && val>-65) && m_direction!='x,-z':
			m_direction='x,-z'
		elif(val<-115 && val>-155) && m_direction!='x,z':
			m_direction='x,z'
		else:
			return
		emit_signal("change_position", m_direction)
		
		


func _on_Player_change_position(position):
	pass # Replace with function body.
