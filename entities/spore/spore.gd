class_name Spore
extends Sprite2D

const QUARTER_TURN: float = PI * .5

@export var maxSpeed: float = 100.0
@export var gravity: float = 50.0
@export var horizontalWindStrength: float = 100
var motion: Vector2 = Vector2.ZERO
var active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	motion.x += horizontalWindStrength * delta
	motion.y += gravity * delta
	if motion.length_squared() > maxSpeed * maxSpeed:
		motion = motion.normalized() * maxSpeed
	position += motion * delta

func _on_timer_timeout():
	self.frame = (self.frame + 1) % (self.hframes * self.vframes)
	self.rotate(QUARTER_TURN)
