extends "res://subscenes/tournament/round_edit_base.gd"

onready var groupSizeInp: LineEdit = $GroupSize/GroupSizeInput
onready var groupNumInp: LineEdit = $GroupNum/GroupNumInput
onready var neededWins: LineEdit = $NeededWins/WinInput

func _ready():
	._ready()
	playerNumberChange()
	if roundRes != null:
		groupSizeInp.text = str(roundRes.groupSize)
		groupNumInp.text = str(roundRes.groupNum)
		neededWins.text = str(roundRes.neededWins)

func attachResource(newRoundRes: RoundResource) -> void:
	if not newRoundRes is GroupRound:
		assert(false, "This UI is for group rounds only.")
		return
	.attachResource(newRoundRes)
	if groupNumInp != null:
		groupSizeInp.text = str(roundRes.groupSize)
		groupNumInp.text = str(roundRes.groupNum)
		neededWins.text = str(roundRes.neededWins)

func _on_GroupSizeInput_text_changed(new_text):
	if str(int(new_text)) != new_text:
		groupSizeInp.text = ""
		roundRes.groupSize = 3
	else:
		roundRes.groupSize = int(new_text)
		groupSizeInp.text = str(roundRes.groupSize)
	playerNumberChange()

func _on_GroupNumInput_text_changed(new_text):
	if str(int(new_text)) != new_text:
		groupNumInp.text = ""
		roundRes.groupNum = 1
	else:
		roundRes.groupNum = int(new_text)
		if groupNumInp.text != str(roundRes.groupNum):
			groupNumInp.text = str(roundRes.groupNum)
	playerNumberChange()

func _on_WinInput_text_changed(new_text):
	if str(int(new_text)) != new_text:
		neededWins.text = ""
		roundRes.neededWins = 1
		return
	roundRes.neededWins = int(new_text)
	neededWins.text = str(roundRes.neededWins)
