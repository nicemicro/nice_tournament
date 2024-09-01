extends VBoxContainer

@onready var nameField: Label = $Header/Name
@onready var raceField: Label = $Race
@onready var avatarPlace: TextureRect = $PlayerIcon
@onready var raceNameContainer: VBoxContainer = $Record/RaceName
@onready var thisTourneyRecord: VBoxContainer = $Record/ThisTourney
@onready var previousTourneyRec: VBoxContainer = $Record/Previously
@onready var leftPoint: Label = $Header/PointLeft
@onready var rightPoint: Label = $Header/PointRight

var _player: PlayerResource
var _playerVs: PlayerResource = null
var _mirrored: bool = false
var _matchPoint: int = 0

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

func setMirror(setMirrored: bool) -> void:
	_mirrored = true

func setMatchPoint(newPoint: int) -> void:
	_matchPoint = newPoint
	if leftPoint != null:
		_showMatchPoints()

func _showMatchPoints() -> void:
	if _mirrored:
		leftPoint.text = str(_matchPoint)
		rightPoint.text = ""
	else:
		rightPoint.text = str(_matchPoint)
		leftPoint.text = ""

func _createLabel(text: String) -> Label:
	var newLabel: Label
	newLabel =  Label.new()
	newLabel.text = text
	return newLabel

func setUpUi() -> void:
	nameField.text = _player.name
	_showMatchPoints()
	if _playerVs == null:
		raceField.text = _player.getRaceName()
	else:
		raceField.text = (
			Global.RaceName[_player.getPlayedRaceVs(_playerVs.getReprRace())]
		)
	var texture: ImageTexture = ImageTexture.create_from_image(_player.avatar)
	avatarPlace.texture = texture
	var currentRecord = Tournament.getCurrentRecord(_player)
	var newLabel: Label =  Label.new()
	for race in Global.Race.values():
		newLabel = _createLabel("vs " + Global.RaceName[race])
		raceNameContainer.add_child(newLabel)
		newLabel = _createLabel(
			str(currentRecord[race]["win"]) + ":" +
			str(currentRecord[race]["loss"])
		)
		thisTourneyRecord.add_child(newLabel)
		newLabel = _createLabel(
			"(" + str(_player.recordVs(race, true)) + ":" +
			str(_player.recordVs(race, false)) + ")"
		)
		previousTourneyRec.add_child(newLabel)
	
