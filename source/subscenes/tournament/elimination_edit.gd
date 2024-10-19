extends "res://subscenes/tournament/round_edit_base.gd"

@onready var pairNumInput: LineEdit = $PairNum/PairNumInput
@onready var neededWins: LineEdit = $NeededWins/WinInput
@onready var inputTypeButton: MenuButton = $InputType/PairNumInput
@onready var inputOrderButton: MenuButton = $InputOrder/PairNumInput

var changeInputType: PopupMenu
var changeInputOrder: PopupMenu

func _ready():
	super._ready()
	playerNumberChange()
	changeInputType = inputTypeButton.get_popup()
	changeInputType.id_pressed.connect(_on_ChangeInputType_pressed)
	changeInputOrder = inputOrderButton.get_popup()
	changeInputOrder.id_pressed.connect(_on_changeInputOrder_pressed)
	if roundRes != null:
		pairNumInput.text = str(roundRes.pairNum)
		neededWins.text = str(roundRes.neededWins)
		inputTypeButton.text = changeInputType.get_item_text(roundRes.inputType)

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

func _on_ChangeInputType_pressed(selectedId: int) -> void:
	roundRes.changeInputType(selectedId)
	inputTypeButton.text = changeInputType.get_item_text(selectedId)

func _on_changeInputOrder_pressed(selectedId: int) -> void:
	roundRes.changeInputOrder(selectedId)
	inputOrderButton.text = changeInputOrder.get_item_text(selectedId)
