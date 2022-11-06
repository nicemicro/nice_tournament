extends VBoxContainer

onready var playerNumber: LineEdit = $HBoxContainer/PlayerCounter
onready var mapPoolEditor: VBoxContainer = $MapPoolEditor

var roundRes: RoundResource

signal playerNumChange

func _ready():
	if roundRes != null:
		mapPoolEditor.attachResource(roundRes)

func attachResource(newRoundRes: RoundResource) -> void:
	if roundRes != null:
		printerr("Resource already set")
		return
	roundRes = newRoundRes
	if mapPoolEditor != null:
		mapPoolEditor.attachResource(roundRes)

func playerNumberChange() -> void:
	playerNumber.text = str(roundRes.output)
	emit_signal("playerNumChange")
