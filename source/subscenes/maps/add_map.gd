extends WindowDialog

onready var mainScreen = $Container
onready var nameField = $Container/Name/LineEdit
onready var prevRecordGroup = $Container/MapRecord
onready var imageButton = $Container/Image
onready var addButton = $Buttons/SaveButton
onready var filedialog = $FileDialog

var _icon: Image = null
var inputFields: Dictionary = {}

signal mapCreated

# Called when the node enters the scene tree for the first time.
func _ready():
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
			newInput.theme = preload("res://fonts/default_theme.tres")
			newInput.text = ""
			newInput.placeholder_text = "0"
			newInput.connect("text_changed", self, "_on_recordLine_text_changed")
			inputFields[winnerRace][loserRace] = newInput
			prevRecordGroup.add_child(newInput)

func createLabel(labelText: String) -> Label:
	var newLabel: Label
	newLabel = Label.new()
	newLabel.text = labelText
	newLabel.theme = preload("res://fonts/default_theme.tres")
	return newLabel

func show():
	addButton.disabled = true
	.show()

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
	_icon = newIcon
	newIcon.resize(250, 250)
	var newButtonTexture: ImageTexture = ImageTexture.new()
	newButtonTexture.create_from_image(newIcon)
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
	self.hide()

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
	self.hide()
