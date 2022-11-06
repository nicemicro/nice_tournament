extends VBoxContainer

onready var playerNumber: LineEdit = $HBoxContainer/PlayerCounter

var roundRes: RoundResource

signal playerNumChange

func attachResource(newRoundRes: RoundResource) -> void:
	if roundRes != null:
		printerr("Resource already set")
		return
	roundRes = newRoundRes

func playerNumberChange() -> void:
	playerNumber.text = str(roundRes.output)
	emit_signal("playerNumChange")
