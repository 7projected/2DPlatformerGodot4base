extends CharacterBody2D
@export var SPEED = 2
var MOVE_DIR = Vector2.ZERO
var GOAL_MOVE :float= 0
@export var GRAVITY :float= 15

@export var JUMP_BUFFER :float= 0.1
@export var JUMP_FORCE :float= 4
@onready var jump_buffer = $JumpBuffer
@export var COYOTE_BUFFER :float= 0.1
@onready var coyote_buffer = $CoyoteBuffer

func _physics_process(_delta):
	move()

func decel():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "GOAL_MOVE", 0, 0.1)

func accel():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "GOAL_MOVE", MOVE_DIR.x, 0.1)

func move():
	MOVE_DIR.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	if Input.is_action_just_pressed("jump"):
		jump_buffer.start(JUMP_BUFFER)
	
	if !is_on_floor():
		MOVE_DIR.y += GRAVITY
	else:
		MOVE_DIR.y = 0
	
	if !coyote_buffer.is_stopped():
		MOVE_DIR.y = 0
	
	if is_on_floor() and !jump_buffer.is_stopped() or !jump_buffer.is_stopped() and !coyote_buffer.is_stopped():
		MOVE_DIR.y -= JUMP_FORCE * 100
		jump_buffer.stop()
		coyote_buffer.stop()
	
	if !is_on_floor() and MOVE_DIR.y < 0 and !Input.is_action_pressed("jump"):
		coyote_buffer.stop()
		var tween = get_tree().create_tween()
		tween.tween_property(self, "MOVE_DIR:y", MOVE_DIR.y * -1 / 2, 0.1)
		MOVE_DIR.y = MOVE_DIR.y * -1 / 5
	
	if MOVE_DIR.x != 0:
		accel()
	else:
		decel()
	
	velocity.x = GOAL_MOVE * SPEED * 100
	velocity.y = MOVE_DIR.y
	var was_on_floor = is_on_floor()
	move_and_slide()

	if was_on_floor and !is_on_floor() and MOVE_DIR.y == 0:
		coyote_buffer.start(COYOTE_BUFFER)
