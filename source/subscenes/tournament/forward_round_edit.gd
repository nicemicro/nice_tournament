extends "res://subscenes/tournament/round_edit_base.gd"

func _ready():
	._ready()
	playerNumberChange()

func attachResource(newRoundRes: RoundResource) -> void:
	if not newRoundRes is ForwardRound:
		assert(false, "This UI is for forward rounds only.")
		return
	.attachResource(newRoundRes)

func _on_PlayerCounter_text_changed(new_text):
	if str(int(new_text)) != new_text:
		playerNumber.text = ""
		roundRes.input = 4
	else:
		roundRes.input = int(new_text)
		if playerNumber.text != str(roundRes.output):
			playerNumber.text = str(roundRes.output)
	emit_signal("playerNumChange")
