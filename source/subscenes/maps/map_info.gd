extends VBoxContainer

@onready var nameField: Label = $Name
@onready var iconPlace: TextureRect = $IconContainer

var _map: MapResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _map != null:
		setUpUi()

func setUpPlayer(map: MapResource) -> void:
	_map = map
	if nameField != null:
		setUpUi()

func setUpUi() -> void:
	nameField.text = _map.name
	var texture: ImageTexture = ImageTexture.new()
	texture.create_from_image(_map.icon)
	iconPlace.texture = texture
