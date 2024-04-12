extends Window

@onready var nameField = $Columns/Col1/Name/LineEdit
@onready var avatarButton = $Columns/Col1/Avatar
@onready var racePicks = $Columns/Col2/RacePicks
@onready var defRacePicker = $Columns/Col2/RacePicks/DefaultRace
@onready var versusInputs = $Columns/Col3/VersusInputs
@onready var mapVetoSelector = $Columns/Col1/Map/OptionButton
@onready var addButton = $Buttons/SaveButton
@onready var filedialog = $FileDialog
@onready var mainScreen = $Columns

var _avatar: Image = null
var _racePickers: Dictionary = {}
var _versusInputs: Dictionary = {}

const raceSelectorScenePath: String = "res://subscenes/players/race_selector.tscn"
const versusInputScenePath: String = "res://subscenes/players/versus_input.tscn"

signal playerCreated

func  _ready():
	defRacePicker.setLabel("Default race")
	defRacePicker.connect("itemSelected", Callable(self, "defRacePicked"))
	for race in Global.RaceName:
		var newScene = preload(raceSelectorScenePath)
		var newNode = newScene.instantiate()
		_racePickers[race] = newNode
		racePicks.add_child(newNode)
		newNode.setLabel("Vs. " + Global.RaceName[race])
	for race in Global.RaceName:
		var newScene = preload(versusInputScenePath)
		var newNode = newScene.instantiate()
		newNode.connect("valueChanged", Callable(self, "validateInputs"))
		_versusInputs[race] = newNode
		versusInputs.add_child(newNode)
		newNode.setLabel("Vs. " + Global.RaceName[race])
	for mapId in Global.maps:
		mapVetoSelector.add_item(Global.maps[mapId].name)

func validateInputs():
	addButton.disabled = true
	if _avatar == null:
		return
	if nameField.text == "":
		return
	for versusInput in _versusInputs.values():
		if not versusInput.validate():
			return
	addButton.disabled = false

func _on_Avatar_pressed():
	mainScreen.hide()
	filedialog.popup()

func _on_FileDialog_file_selected(path):
	var newAvatar: Image = Image.new()
	newAvatar.load(path)
	_avatar = newAvatar.duplicate()
	newAvatar.resize(250, 250)
	var newButtonTexture: ImageTexture = ImageTexture.new()
	newButtonTexture.create_from_image(newAvatar)
	avatarButton.texture_normal = newButtonTexture
	mainScreen.show()
	validateInputs()

func _on_FileDialog_popup_hide():
	mainScreen.show()

func defRacePicked(index):
	for racePicker in _racePickers.values():
		racePicker.setSelection(index)

func _on_LineEdit_text_changed(new_text):
	validateInputs()

func _on_CancelButton_pressed():
	self.hide()

func _on_SaveButton_pressed():
	var raceDict: Dictionary = {}
	var recordDict: Dictionary = {}
	var winLoss: Dictionary = {}
	var vetodMap: MapResource
	for race in _racePickers:
		raceDict[race] = _racePickers[race].getSelection()
	for race in _versusInputs:
		winLoss = {}
		winLoss["win"] = _versusInputs[race].getWin()
		winLoss["loss"] = _versusInputs[race].getLoss()
		recordDict[race] = winLoss
	vetodMap = Global.maps[Global.maps.keys()[mapVetoSelector.selected]]
	var playerResource: PlayerResource = PlayerResource.new(
		nameField.text,
		_avatar,
		vetodMap,
		raceDict,
		recordDict
	)
	emit_signal("playerCreated", playerResource)
	self.hide()


func _on_visibility_changed():
	if visible:
		addButton.disabled = true
