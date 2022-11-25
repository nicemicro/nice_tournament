extends VBoxContainer

onready var avatarsList: VBoxContainer = $PlayerList/Avatars
onready var namesList: VBoxContainer = $PlayerList/Names
onready var winsList: VBoxContainer = $PlayerList/Wins
onready var colonList: VBoxContainer = $PlayerList/Colons
onready var lossesList: VBoxContainer = $PlayerList/Losses
onready var openButton: TextureButton = $OpenButton

var fullScreen: bool = false
var startedMatch: bool = false
var playerNodes: Array = []
var groupList: Array = []
var showPoint: bool = false
var virtualPointMult: float = 0

signal openGroup

func _ready():
	if fullScreen:
		openButton.visible = true
		for playerDict in groupList:
			if playerDict == null:
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

func matchStarted() -> void:
	startedMatch = true

func showPrevPoints(NewVPM: float) -> void:
	showPoint = true
	virtualPointMult = NewVPM

func addGroup(newGroupList: Array) -> void:
	if len(groupList) > 0:
		printerr("Can't change this on the fly.")
		return
	groupList = newGroupList
	if namesList != null:
		_showGroup()

func _showGroup():
	var nameString: String
	for playerDict in groupList:
		if playerDict == null:
			if fullScreen:
				var texture: ImageTexture = ImageTexture.new()
				texture.create(60, 60, Image.FORMAT_RGB8)
				var avatarDisp: TextureRect = TextureRect.new()
				avatarDisp.rect_min_size = Vector2(0, 60)
				avatarDisp.texture = texture
				avatarDisp.size_flags_vertical = SIZE_SHRINK_CENTER
				avatarsList.add_child(avatarDisp)
			_addPlayerNode("???", "-", "-")
			continue
		nameString = playerDict["player"].name
		if showPoint:
			var pointString: String = "("
			pointString = (
				pointString +
				str(playerDict["player"].getPoints() - playerDict["win"])
			)
			if virtualPointMult > 0:
				pointString = (
					pointString + "+" +
					str(playerDict["player"].virtualPoints * virtualPointMult)
				)
			pointString = pointString + ") "
			nameString =  pointString + nameString
		if fullScreen:
			var miniAvatar: Image = playerDict["player"].avatar.duplicate()
			miniAvatar.resize(60, 60)
			var texture: ImageTexture = ImageTexture.new()
			texture.create_from_image(miniAvatar)
			var avatarDisp: TextureRect = TextureRect.new()
			avatarDisp.rect_min_size = Vector2(0, 60)
			avatarDisp.texture = texture
			avatarDisp.size_flags_vertical = SIZE_SHRINK_CENTER
			avatarsList.add_child(avatarDisp)
		_addPlayerNode(
			nameString,
			str(playerDict["win"]),
			str(playerDict["loss"])
		)
	if len(groupList) == 1 or not startedMatch:
		openButton.disabled = true
	if len(groupList) <= 2:
		colonList.visible = false
		lossesList.visible = false

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
		textLabel.rect_min_size = Vector2(0, 60)
	if center:
		textLabel.size_flags_horizontal = SIZE_SHRINK_CENTER
	parent.add_child(textLabel)

func _on_OpenButton_pressed():
	emit_signal("openGroup", groupList)
