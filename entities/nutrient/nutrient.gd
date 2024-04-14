class_name Nutrient
extends Sprite2D

@export var frame_delay: float = 0.25
var time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	self.frame = int(time / frame_delay) % (self.hframes * self.vframes)
