extends VBoxContainer

@onready var nameField: Label = $Name
@onready var raceField: Label = $Race
@onready var avatarPlace: TextureRect = $AvatarContainer

var _player: PlayerResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _player != null:
		setUpUi()

func setUpPlayer(player: PlayerResource) -> void:
	_player = player
	if nameField != null:
		setUpUi()

func setUpUi() -> void:
	nameField.text = _player.name
	raceField.text = _player.getRaceName()
	var texture: ImageTexture = ImageTexture.create_from_image(_player.avatar)
	avatarPlace.texture = texture
