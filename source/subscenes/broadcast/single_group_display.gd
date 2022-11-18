extends VBoxContainer

onready var namesList: VBoxContainer = $PlayerList/Names
onready var winsList: VBoxContainer = $PlayerList/Wins
onready var colonList: VBoxContainer = $PlayerList/Colons
onready var lossesList: VBoxContainer = $PlayerList/Losses
onready var openButton: TextureButton = $OpenButton

var fullScreen: bool = false
var playerNodes: Array = []
var groupList: Array = []

signal openGroup

func _ready():
	if fullScreen:
		openButton.visible = true
		for playerDict in groupList:
			if len(playerDict) == 0:
				openButton.visible = false
				break
	if len(groupList) > 0:
		_showGroup()

func setFullScreen() -> void:
	fullScreen = true
	if openButton != null:
		openButton.visible = true
		for playerDict in groupList:
			if len(playerDict) == 0:
				openButton.visible = false
				break

func addGroup(newGroupList: Array) -> void:
	if len(groupList) > 0:
		printerr("Can't change this on the fly.")
		return
	groupList = newGroupList
	if namesList != null:
		_showGroup()

func _showGroup():
	for playerDict in groupList:
		if len(playerDict) == 0:
			_addPlayerNode("???", "-", "-")
			continue
		_addPlayerNode(
			playerDict["player"].name,
			str(playerDict["win"]),
			str(playerDict["loss"])
		)

func _addPlayerNode(name: String, wins: String, losses: String) -> void:
	_addTextLabel(name, namesList)
	_addTextLabel(wins, winsList, true)
	_addTextLabel(":", colonList, true)
	_addTextLabel(losses, lossesList, true)

func _addTextLabel(text: String, parent: Control, center: bool = false) -> void:
	var textLabel: Label
	textLabel = Label.new()
	textLabel.text = text
	textLabel.valign = Label.VALIGN_CENTER
	if fullScreen:
		textLabel.theme_type_variation = "LabelLarge"
	if center:
		textLabel.size_flags_horizontal = SIZE_SHRINK_CENTER
	parent.add_child(textLabel)

func _on_OpenButton_pressed():
	emit_signal("openGroup", groupList)
