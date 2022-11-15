extends MarginContainer

onready var nameField: Label = $HeaderFooter/Name
onready var raceField: Label = $HeaderFooter/Split/InfoContainer/Race
onready var avatarPlace: TextureRect = $HeaderFooter/Split/AvatarContainer
onready var infoContainer: VBoxContainer = $HeaderFooter/Split/InfoContainer

var _player: PlayerResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _player != null:
		setUpUi()

func attachResource(player: PlayerResource) -> void:
	assert(player is PlayerResource)
	_player = player
	if nameField != null:
		setUpUi()

func setUpUi() -> void:
	nameField.text = _player.name
	raceField.text = _player.getRaceName()
	var texture: ImageTexture = ImageTexture.new()
	texture.create_from_image(_player.avatar)
	avatarPlace.texture = texture
	for race in Global.Race.values():
		var newLabel: Label =  Label.new()
		newLabel.text = (
			"vs " + Global.RaceName[race] + ": " +
			str(_player.recordVs(race, true)) + ":" +
			str(_player.recordVs(race, false))
		)
		newLabel.theme_type_variation = "LabelSmall"
		infoContainer.add_child(newLabel)
