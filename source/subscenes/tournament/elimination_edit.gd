extends "res://subscenes/tournament/round_edit_base.gd"

@onready var pairNumInput: LineEdit = $PairNum/PairNumInput
@onready var neededWins: LineEdit = $NeededWins/WinInput

func _ready():
	super._ready()
	playerNumberChange()
	if roundRes != null:
		pairNumInput.text = str(roundRes.pairNum)
		neededWins.text = str(roundRes.neededWins)

func attachResource(newRoundRes: RoundResource) -> void:
	if not newRoundRes is EliminationRound:
		assert(false, "This UI is for elimination rounds only.")
		return
	super.attachResource(newRoundRes)
	if pairNumInput != null:
		pairNumInput.text = str(roundRes.pairNum)
		neededWins.text = str(roundRes.neededWins)

func _on_PairNumInput_text_changed(new_text):
	if str(int(new_text)) != new_text:
		pairNumInput.text = ""
		roundRes.pairNum = 1
	else:
		roundRes.pairNum = int(new_text)
		if pairNumInput.text != str(roundRes.pairNum):
			pairNumInput.text = str(roundRes.pairNum)
	playerNumberChange()

func _on_WinInput_text_changed(new_text):
	if str(int(new_text)) != new_text:
		neededWins.text = ""
		roundRes.neededWins = 1
		return
	roundRes.neededWins = int(new_text)
	neededWins.text = str(roundRes.neededWins)

