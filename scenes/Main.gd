extends Node

@onready var camera: Camera2D = get_node("Camera2D")
@onready var spore: Spore = get_node("Spore")
@onready var background: Sprite2D = get_node("Land")
@onready var groundY: float = get_node("GroundMarker").position.y

@export var accelerationAmount: Vector2 = Vector2(-200, -500)
@export var cameraOffsetX: float = 128

@onready var viewportWidth: float = ProjectSettings.get_setting("display/window/size/viewport_width")
@onready var viewportHeight: float = ProjectSettings.get_setting("display/window/size/viewport_height")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	camera.position = Vector2(spore.position.x + cameraOffsetX, min((spore.position.y + background.region_rect.size.y) * .5, spore.position.y + viewportHeight / 2 - spore.texture.get_size().y / 2))

func _physics_process(delta):
	if Input.is_action_pressed("fly_up"):
		var windStrength = spore.position.y / groundY
		spore.motion += accelerationAmount * (windStrength * delta)
		print(spore.motion)
