extends HBoxContainer

onready var namesList: VBoxContainer = $Names
onready var winsList: VBoxContainer = $Wins
onready var colonList: VBoxContainer = $Colons
onready var lossesList: VBoxContainer = $Losses

var playerNodes: Array = []
var groupList: Array = []

func _ready():
	if len(groupList) > 0:
		_showGroup()

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
	var textLabel: Label
	textLabel = Label.new()
	textLabel.text = name
	namesList.add_child(textLabel)
	textLabel = Label.new()
	textLabel.size_flags_horizontal = SIZE_SHRINK_CENTER
	textLabel.text = wins
	winsList.add_child(textLabel)
	textLabel = Label.new()
	textLabel.size_flags_horizontal = SIZE_SHRINK_CENTER
	textLabel.text = ":"
	colonList.add_child(textLabel)
	textLabel = Label.new()
	textLabel.size_flags_horizontal = SIZE_SHRINK_CENTER
	textLabel.text = losses
	lossesList.add_child(textLabel)
