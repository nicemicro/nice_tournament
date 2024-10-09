extends MarginContainer

@onready var nameField: Label = $HeaderFooter/Header/Name
@onready var raceField: Label = $HeaderFooter/Header/Race
@onready var rankingField: Label = $HeaderFooter/Header/Ranking
@onready var avatarPlace: TextureRect = $HeaderFooter/Split/AvatarContainer
@onready var infoContainer: VBoxContainer = $HeaderFooter/Split/InfoContainer

var _player: PlayerResource
var _playerVs: PlayerResource = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _player != null:
		setUpUi()

func attachResource(player: PlayerResource, playerVs: PlayerResource = null) -> void:
	assert(player is PlayerResource)
	_player = player
	_playerVs = playerVs
	if nameField != null:
		setUpUi()

func setUpUi() -> void:
	nameField.text = _player.name
	if _playerVs == null:
		raceField.text = "[" + _player.getRaceName() + "]"
	else:
		raceField.text = (
			"["+
			Global.RaceName[_player.getPlayedRaceVs(_playerVs.getReprRace())] +
			"]"
		)
	if _player.ranking == -1:
		rankingField.text = "(no ranking)"
	else:
		rankingField.text = str(_player.ranking)
	var texture: ImageTexture = ImageTexture.create_from_image(_player.avatar)
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
	var newLabel2: Label =  Label.new()
	newLabel2.text = (
		"Veto: " + _player.mapVeto.name
	)
	newLabel2.theme_type_variation = "LabelSmall"
	infoContainer.add_child(newLabel2)
