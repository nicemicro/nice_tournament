extends VBoxContainer

onready var playerNumber: LineEdit = $HBoxContainer/PlayerCounter
onready var vpSlider: HSlider = $VirtualPointMult/VPMSlider
onready var vpNumber: LineEdit = $VirtualPointMult/VPMValue
onready var mapPoolEditor: VBoxContainer = $MapPoolEditor

var roundRes: RoundResource

signal playerNumChange

func _ready():
	if roundRes != null:
		mapPoolEditor.attachResource(roundRes)
		playerNumber.text = str(roundRes.input)
		vpNumber.text = str(roundRes.virtualInputMult)
		vpSlider.value = round(roundRes.virtualInputMult * 100)
		emit_signal("playerNumChange")

func attachResource(newRoundRes: RoundResource) -> void:
	if roundRes != null:
		printerr("Resource already set")
		return
	roundRes = newRoundRes
	if mapPoolEditor != null:
		mapPoolEditor.attachResource(roundRes)
		playerNumber.text = str(roundRes.input)
		vpNumber.text = str(roundRes.virtualInputMult)
		vpSlider.value = round(roundRes.virtualInputMult)
		emit_signal("playerNumChange")

func playerNumberChange() -> void:
	playerNumber.text = str(roundRes.output)
	emit_signal("playerNumChange")

func _on_VPMSlider_drag_ended(value_changed):
	vpNumber.text = str(vpSlider.value / 100)
	roundRes.virtualInputMult = vpSlider.value / 100
