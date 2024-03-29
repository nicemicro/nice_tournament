extends "res://subscenes/tournament/round_edit_base.gd"

@onready var neededWins: LineEdit = $NeededWins/WinInput

func _ready():
	super._ready()
	playerNumberChange()
	if roundRes != null:
		neededWins.text = str(roundRes.neededWins)

func attachResource(newRoundRes: RoundResource) -> void:
	if not newRoundRes is SwissRound:
		assert(false, "This UI is for swiss rounds only.")
		return
	super.attachResource(newRoundRes)
	if neededWins != null:
		neededWins.text = str(roundRes.neededWins)

func _on_PlayerCounter_text_changed(new_text):
	if str(int(new_text)) != new_text:
		playerNumber.text = ""
		roundRes.input = 4
	else:
		roundRes.input = int(new_text)
		if playerNumber.text != str(roundRes.output):
			playerNumber.text = str(roundRes.output)
	emit_signal("playerNumChange")


func _on_WinInput_text_changed(new_text):
	if str(int(new_text)) != new_text:
		neededWins.text = ""
		roundRes.neededWins = 1
		return
	roundRes.neededWins = int(new_text)
	neededWins.text = str(roundRes.neededWins)
