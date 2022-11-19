extends HBoxContainer

onready var mapNameLabel: Label = $MapName
onready var leftButton: TextureButton = $Left/WinButton
onready var rightButton: TextureButton = $Right/WinButton
onready var leftWonLabel: Label = $Left/Label
onready var rightWonLabel: Label = $Right/Label

var mapName: String = ""
var active: bool = false
var winnerLeft: int = -1

signal leftWon
signal rightWon

func _ready():
	if mapName != "":
		setLooks()

func setMapName(newName: String):
	mapName = newName
	if mapNameLabel != null:
		mapNameLabel.text = mapName

func setActive():
	active = true
	if leftButton != null:
		setLooks()

func setWinner(left: bool):
	if left:
		winnerLeft = 1
	else:
		winnerLeft = 0
	if leftButton != null:
		setLooks()

func setLooks():
	mapNameLabel.text = mapName
	if active:
		leftButton.disabled = false
		rightButton.disabled = false
		return
	if winnerLeft == -1:
		return
	leftButton.visible = false
	rightButton.visible = false
	leftWonLabel.visible = true
	rightWonLabel.visible = true
	if winnerLeft == 1:
		rightWonLabel.text = ""
	else:
		leftWonLabel.text = ""

func _on_LeftWinButton_pressed():
	active = false
	setWinner(true)
	emit_signal("leftWon")

func _on_RightWinButton_pressed():
	active = false
	setWinner(false)
	emit_signal("rightWon")
