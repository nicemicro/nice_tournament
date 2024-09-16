extends Window

@onready var mainScreen = $Container
@onready var nameField = $Container/Name/LineEdit
@onready var prevRecordGroup = $Container/MapRecord
@onready var imageButton = $Container/Image
@onready var addButton = $Buttons/SaveButton
@onready var filedialog = $FileDialog
@onready var findPrevScreen = $LoadPrevious
@onready var findPrevList = $LoadPrevious/Scroll/ListOfPlayers

const oldResultSearchScenePath: String = "res://subscenes/players/load_previous.tscn"

var _icon: Image = null
var _previousMaps: Dictionary = {}
var inputFields: Dictionary = {}

signal mapCreated

# Called when the node enters the scene tree for the first time.
func _ready():
	addButton.disabled = true
	prevRecordGroup.columns = len(Global.Race) + 1
	prevRecordGroup.add_child(createLabel("Won"))
	for loserRace in Global.Race.values():
		prevRecordGroup.add_child(createLabel(
			"vs " + Global.RaceName[loserRace]
		))
	for winnerRace in Global.Race.values():
		inputFields[winnerRace] = {}
		prevRecordGroup.add_child(createLabel(
			Global.RaceName[winnerRace] + ":"
		))
		for loserRace in Global.Race.values():
			if loserRace == winnerRace:
				prevRecordGroup.add_child(createLabel("X"))
				continue
			var newInput: LineEdit = LineEdit.new()
			#newInput.theme = preload("res://themes_fonts/default_theme.tres")
			newInput.text = ""
			newInput.placeholder_text = "0"
			newInput.connect("text_changed", Callable(self, "_on_recordLine_text_changed"))
			inputFields[winnerRace][loserRace] = newInput
			prevRecordGroup.add_child(newInput)
	var mapIndex: int = 0
	for mapName in Global.previousMaps:
		if mapName in Global.getMapNames():
			continue
		var newScene = preload(oldResultSearchScenePath)
		var newNode = newScene.instantiate()
		newNode.setLabel(mapName)
		newNode.setId(mapIndex)
		_previousMaps[mapIndex] = mapName
		newNode.itemSelected.connect(_on_PreviousSelected)
		findPrevList.add_child(newNode)
		mapIndex += 1

func createLabel(labelText: String) -> Label:
	var newLabel: Label
	newLabel = Label.new()
	newLabel.text = labelText
	#newLabel.theme = preload("res://themes_fonts/default_theme.tres")
	return newLabel

func validateInputs():
	addButton.disabled = true
	if _icon == null:
		return
	if nameField.text == "":
		return
	for winners in inputFields.values():
		for inputField in winners.values():
			if (
				inputField.text != "" and
				inputField.text != str(int(inputField.text))
			):
				return
	addButton.disabled = false

func _on_Image_pressed():
	mainScreen.hide()
	filedialog.popup()

func _on_FileDialog_file_selected(path):
	var newIcon: Image = Image.new()
	newIcon.load(path)
	_icon = newIcon.duplicate()
	newIcon.resize(250, 250)
	var newButtonTexture: ImageTexture = ImageTexture.create_from_image(newIcon)
	imageButton.texture_normal = newButtonTexture
	mainScreen.show()
	validateInputs()

func _on_FileDialog_popup_hide():
	mainScreen.show()

func _on_LineEdit_text_changed(new_text):
	validateInputs()

func _on_recordLine_text_changed(new_text):
	validateInputs()

func _on_CancelButton_pressed():
	queue_free()

func _on_SaveButton_pressed():
	var previousRecord: Dictionary = {}
	for winnerRace in inputFields:
		previousRecord[winnerRace] = {}
		for loserRace in inputFields[winnerRace]:
			previousRecord[winnerRace][loserRace] = int(
				inputFields[winnerRace][loserRace].text
			)
	var mapResource: MapResource = MapResource.new(
		nameField.text,
		_icon,
		previousRecord
	)
	emit_signal("mapCreated", mapResource)
	queue_free()

func _on_visibility_changed():
	if addButton == null:
		return
	if visible:
		addButton.disabled = true

func _on_search_button_pressed():
	findPrevScreen.show()
	mainScreen.hide()

func _on_PreviousSelected(id: int):
	var mapName: String = _previousMaps[id]
	nameField.text = mapName
	var currentMap: Dictionary = Global.previousMaps[mapName]
	for winRace in currentMap:
		for loseRace in currentMap[winRace]:
			if winRace == loseRace:
				continue
			inputFields[winRace][loseRace].text = str(
				currentMap[winRace][loseRace]
			)
	mainScreen.show()
	findPrevScreen.hide()

func _on_load_previous_close_requested():
	mainScreen.show()
	findPrevScreen.hide()
