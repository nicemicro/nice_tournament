extends WindowDialog

onready var mainScreen = $Container
onready var nameField = $Container/Name/LineEdit
onready var imageButton = $Container/Image
onready var addButton = $Buttons/SaveButton
onready var filedialog = $FileDialog

signal mapCreated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var _icon: Image = null

func show():
	addButton.disabled = true
	.show()

func validateInputs():
	addButton.disabled = true
	if _icon == null:
		return
	if nameField.text == "":
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

func _on_CancelButton_pressed():
	self.hide()

func _on_SaveButton_pressed():
	var mapResource: MapResource = MapResource.new(
		nameField.text,
		_icon
	)
	emit_signal("mapCreated", mapResource)
	self.hide()
