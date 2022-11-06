extends "res://subscenes/tournament/round_edit_base.gd"

onready var groupNumInp: LineEdit = $GroupNum/GroupNumInput
onready var WinsFirstInp: LineEdit = $WinsFirst/WinInput
onready var WinsWinLosInp: LineEdit = $WinsWinnerLoser/WinInput
onready var WinsFinalInp: LineEdit = $WinsFinal/WinInput

func _ready():
	._ready()
	playerNumberChange()

func attachResource(newRoundRes: RoundResource) -> void:
	if not newRoundRes is DualTourneyRound:
		assert(false, "This UI is for dual tournament rounds only.")
		return
	.attachResource(newRoundRes)

func _on_GroupNumInput_text_changed(new_text):
	if str(int(new_text)) != new_text:
		groupNumInp.text = ""
		roundRes.groupNum = 1
	else:
		roundRes.groupNum = int(new_text)
		groupNumInp.text = str(roundRes.groupNum)
	playerNumberChange()

func _on_WinFirst_text_changed(new_text):
	var winsList: Array = roundRes.neededWins
	if str(int(new_text)) != new_text:
		WinsFirstInp.text = ""
		winsList[0] = 1
		roundRes.neededWins = winsList
		return
	winsList[0] = int(new_text)
	roundRes.neededWins = winsList
	WinsFirstInp.text = str(roundRes.neededWins[0])

func _on_WinWL_text_changed(new_text):
	var winsList: Array = roundRes.neededWins
	if str(int(new_text)) != new_text:
		WinsWinLosInp.text = ""
		winsList[1] = 2
		roundRes.neededWins = winsList
		return
	winsList[1] = int(new_text)
	roundRes.neededWins = winsList
	WinsWinLosInp.text = str(roundRes.neededWins[1])

func _on_WinFinal_text_changed(new_text):
	var winsList: Array = roundRes.neededWins
	if str(int(new_text)) != new_text:
		WinsFinalInp.text = ""
		winsList[2] = 2
		roundRes.neededWins = winsList
		return
	winsList[2] = int(new_text)
	roundRes.neededWins = winsList
	WinsFinalInp.text = str(roundRes.neededWins[2])
