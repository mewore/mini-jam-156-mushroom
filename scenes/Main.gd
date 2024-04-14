extends Node

@onready var camera: Camera2D = get_node("Camera2D")
@onready var spore: Spore = get_node("Spore")
@onready var background: Sprite2D = get_node("ParallaxBackground/BackgroundLayer/Background")
@onready var groundBottom := background.region_rect.size.y
@onready var groundTop: float = get_node("GroundMarker").position.y

@onready var nutrientContainer: Node = get_node("Nutrients")
@export var nutrientNoise: Noise
@export var nutrientScene: PackedScene = null

@export var accelerationAmount: Vector2 = Vector2(-200, -500)
@export var cameraOffsetX: float = 128

@onready var viewportWidth: float = ProjectSettings.get_setting("display/window/size/viewport_width")
@onready var viewportHeight: float = ProjectSettings.get_setting("display/window/size/viewport_height")

@onready var nutrientChunkWidth = get_node("Nutrients/ChunkWidth").position.x
var firstGeneratedChunk = 0;
var lastGeneratedChunk = -1
var discardedNutrients := Array()
@export var pixelsPerNutrientSample := 256
@export_range(0, 1) var nutrientThreshold = .5
@onready var nutrientPreview: Sprite2D = get_node("Nutrients/NutrientPreview")
@onready var nutrientNoiseContainer: Node = get_node("Nutrients/NutrientNoise")
const NUTRIENT_SAMPLE_COUNT := 5
const NUTRIENT_SAMPLE_INITIAL_RADIUS := 2.0
var nutrientSampleTransform = Transform2D(1.618033988749 * 2 * PI, Vector2.ONE * 1.5, 0.0, Vector2.ZERO)
var leftmostGeneratedNoise := 0
var rightmostGeneratedNoise := -1

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("HueShift").visible = true
	camera.limit_bottom = floor(background.region_rect.size.y)
	var nutrientTexture: NoiseTexture2D = nutrientPreview.texture.duplicate()
	nutrientPreview.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	camera.position = Vector2(max(camera.position.x, spore.position.x + cameraOffsetX),
		min((spore.position.y + groundBottom) * .5, spore.position.y + viewportHeight / 2 - spore.texture.get_size().y * 2))
	
	var left: float = min(spore.global_position.x, camera.global_position.x) - viewportWidth
	var right: float = max(spore.global_position.x, camera.global_position.x) + viewportWidth

	var minY := groundTop
	var leftmostChunk := int(left / nutrientChunkWidth)
	if leftmostChunk > firstGeneratedChunk:
		for nutrient in nutrientContainer.get_children():
			if nutrient is Nutrient and nutrient.visible and nutrient.global_position.x < left:
				nutrient.visible = false
				discardedNutrients.append(nutrient)
		firstGeneratedChunk = leftmostChunk
	
	var rightmostChunk := int(right / nutrientChunkWidth)
		
	while lastGeneratedChunk < rightmostChunk:
		lastGeneratedChunk += 1
		
		var newNutrientNoiseSprite: Sprite2D = null
		var newNutrientNoiseSpriteName := "NutrientNoise" + str(lastGeneratedChunk)
		if leftmostGeneratedNoise < leftmostChunk:
			newNutrientNoiseSprite = nutrientNoiseContainer.get_node("NutrientNoise" + str(leftmostGeneratedNoise))
			leftmostGeneratedNoise += 1
		if newNutrientNoiseSprite == null:
			newNutrientNoiseSprite = nutrientPreview.duplicate()
			newNutrientNoiseSprite.visible = true
			nutrientNoiseContainer.add_child(newNutrientNoiseSprite)
		newNutrientNoiseSprite.name = newNutrientNoiseSpriteName
		newNutrientNoiseSprite.position = Vector2(lastGeneratedChunk * nutrientChunkWidth, groundTop)
		var nutrientTextureNoise: FastNoiseLite = nutrientNoise.duplicate()
		nutrientTextureNoise.offset = Vector3(newNutrientNoiseSprite.position.x, newNutrientNoiseSprite.position.y, 0.0)
		var nutrientTexture: NoiseTexture2D = NoiseTexture2D.new()
		nutrientTexture.set_width(nutrientChunkWidth)
		nutrientTexture.set_height(groundBottom - groundTop)
		nutrientTexture.color_ramp = nutrientPreview.texture.color_ramp
		nutrientTexture.noise = nutrientTextureNoise
		newNutrientNoiseSprite.texture = nutrientTexture
		
		print("Generating chunk: ", lastGeneratedChunk)
		var pixelsPerChunk = (groundBottom - groundTop) * nutrientChunkWidth
		var nutrientSamplesPerChunk = pixelsPerChunk / pixelsPerNutrientSample
		for sample in range(nutrientSamplesPerChunk):
			var nutrientPosition := Vector2(
				randf_range(lastGeneratedChunk * nutrientChunkWidth, (lastGeneratedChunk + 1) * nutrientChunkWidth),
				randf_range(groundTop, groundBottom))
			var noiseMultiplier = inverse_lerp(groundTop, groundBottom, nutrientPosition.y)
			noiseMultiplier = min(noiseMultiplier, sqrt(sqrt(1.0 - noiseMultiplier)))
			var noiseValue = (nutrientNoise.get_noise_2dv(nutrientPosition) + .5) * noiseMultiplier
			# var sampleOffset := Vector2.RIGHT.rotated(randf_range(0, PI * 2)) * NUTRIENT_SAMPLE_INITIAL_RADIUS
			# if minNoise > nutrientThreshold:
			# 	minNoise = min(minNoise, nutrientNoise.get_noise_2dv(nutrientPosition + sampleOffset) * noiseMultiplier)
			# 	sampleOffset *= nutrientSampleTransform
			if noiseValue < nutrientThreshold or noiseValue < randf():
				continue
			var nutrient: Nutrient
			# print("Nutrient at: ", nutrientPosition)
			if discardedNutrients.is_empty():
				nutrient = nutrientScene.instantiate()
				nutrientContainer.add_child(nutrient)
			else:
				nutrient = discardedNutrients.pop_back()
				nutrient.visible = true
			nutrient.position = nutrientPosition
	

func _physics_process(delta):
	if Input.is_action_pressed("fly_up"):
		var windStrength = spore.position.y / groundTop
		spore.motion += accelerationAmount * (windStrength * delta)
