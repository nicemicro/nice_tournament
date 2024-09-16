extends Window

@onready var nameField = $Columns/Col1/Name/LineEdit
@onready var avatarButton = $Columns/Col1/Avatar
@onready var racePicks = $Columns/Col2/RacePicks
@onready var defRacePicker = $Columns/Col2/RacePicks/DefaultRace
@onready var rankField = $Columns/Col3/RankScore/LineEdit
@onready var versusInputs = $Columns/Col3/VersusInputs
@onready var mapVetoSelector = $Columns/Col1/Map/OptionButton
@onready var addButton = $Buttons/SaveButton
@onready var filedialog = $FileDialog
@onready var mainScreen = $Columns
@onready var cancelPrevDataButton = $Columns/Col1/FindPrevious/Cancel
@onready var findPrevScreen = $LoadPrevious
@onready var findPrevList = $LoadPrevious/Scroll/ListOfPlayers

var _avatar: Image = null
var _racePickers: Dictionary = {}
var _versusInputs: Dictionary = {}
var _previousPlayers: Dictionary = {}
var _selectedPrevRecs: Dictionary = {}

const raceSelectorScenePath: String = "res://subscenes/players/race_selector.tscn"
const versusInputScenePath: String = "res://subscenes/players/versus_input.tscn"
const oldResultSearchScenePath: String = "res://subscenes/players/load_previous.tscn"

signal playerCreated

func  _ready():
	defRacePicker.setLabel("Default race")
	defRacePicker.itemSelected.connect(racePicked)
	addButton.disabled = true
	for race in Global.RaceName:
		var newScene = preload(raceSelectorScenePath)
		var newNode = newScene.instantiate()
		_racePickers[race] = newNode
		racePicks.add_child(newNode)
		newNode.setLabel("Vs. " + Global.RaceName[race])
		newNode.setId(race)
		newNode.itemSelected.connect(racePicked)
	for race in Global.RaceName:
		var newScene = preload(versusInputScenePath)
		var newNode = newScene.instantiate()
		newNode.valueChanged.connect(validateInputs)
		_versusInputs[race] = newNode
		versusInputs.add_child(newNode)
		newNode.setLabel("Vs. " + Global.RaceName[race])
	for mapId in Global.maps:
		mapVetoSelector.add_item(Global.maps[mapId].name)
	var playerIndex: int = 0
	for playerName in Global.previousResults:
		if playerName in Global.getPlayerNames():
			continue
		for raceNum in Global.previousResults[playerName]:
			var newScene = preload(oldResultSearchScenePath)
			var newNode = newScene.instantiate()
			var text: String = playerName + " (" + Global.RaceName[raceNum]
			if Global.previousResults[playerName][raceNum]["rank"] != null:
				text += ", " + str(Global.previousResults[playerName][raceNum]["rank"])
			text += ")"
			newNode.setLabel(text)
			newNode.setId(playerIndex)
			newNode.itemSelected.connect(_on_PreviousSelected)
			findPrevList.add_child(newNode)
			_previousPlayers[playerIndex] = {
				"name": playerName, "race": raceNum
			}
			playerIndex += 1

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
	var newButtonTexture: ImageTexture = ImageTexture.create_from_image(newAvatar)
	avatarButton.texture_normal = newButtonTexture
	mainScreen.show()
	validateInputs()

func _on_FileDialog_popup_hide():
	mainScreen.show()

func racePicked(index, id):
	if id > -1:
		if len(_selectedPrevRecs) > 0:
			if index in _selectedPrevRecs:
				_versusInputs[id].setWinLoss(
					_selectedPrevRecs[index]["results"][id]["win"],
					_selectedPrevRecs[index]["results"][id]["loss"]
				)
			else:
				_versusInputs[id].setWinLoss(-1, -1)
		return
	for racePicker in _racePickers.values():
		racePicker.setSelection(index)
	if len(_selectedPrevRecs) > 0:
		if (
			index in _selectedPrevRecs and
			_selectedPrevRecs[index]["rank"] != null
		):
			rankField.text = str(_selectedPrevRecs[index]["rank"])
		else:
			rankField.text = ""
		for vsRace in _versusInputs:
			if index in _selectedPrevRecs:
				_versusInputs[vsRace].setWinLoss(
					_selectedPrevRecs[index]["results"][vsRace]["win"],
					_selectedPrevRecs[index]["results"][vsRace]["loss"]
				)
			else:
				_versusInputs[vsRace].setWinLoss(-1, -1)

func _on_LineEdit_text_changed(new_text):
	validateInputs()

func _on_CancelButton_pressed():
	queue_free()

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
	queue_free()

func _on_visibility_changed():
	if addButton == null:
		return
	if visible:
		addButton.disabled = true

func _on_file_dialog_canceled():
	mainScreen.show()

func _on_search_button_pressed():
	findPrevScreen.show()
	mainScreen.hide()

func _on_PreviousSelected(id: int):
	var playerName: String = _previousPlayers[id]["name"]
	var raceId: int = _previousPlayers[id]["race"]
	nameField.text = playerName
	_selectedPrevRecs = Global.previousResults[playerName].duplicate()
	if _selectedPrevRecs[raceId]["rank"] != null:
		rankField.text = str(_selectedPrevRecs[raceId]["rank"])
	defRacePicker.setOption(raceId)
	for racePicker in _racePickers:
		_racePickers[racePicker].setOption(raceId)
	for vsRaceId in _versusInputs:
		if not vsRaceId in _selectedPrevRecs[raceId]["results"]:
			continue
		_versusInputs[vsRaceId].setWinLoss(
			_selectedPrevRecs[raceId]["results"][vsRaceId]["win"],
			_selectedPrevRecs[raceId]["results"][vsRaceId]["loss"]
		)
	cancelPrevDataButton.disabled = false
	mainScreen.show()
	findPrevScreen.hide()

func _on_load_previous_close_requested():
	mainScreen.show()
	findPrevScreen.hide()

func _on_cancelPrev_pressed():
	_selectedPrevRecs = {}
	cancelPrevDataButton.disabled = true
