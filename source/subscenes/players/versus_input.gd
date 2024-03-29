extends HBoxContainer

@onready var label = $RaceLabel
@onready var win = $Wins
@onready var loss = $Losses

var _labelText: String = ""

signal valueChanged

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = _labelText

func setLabel(text: String) -> void:
	_labelText = text
	if label == null:
		return
	label.text = text

func validate() -> bool:
	if win.text != "" and str(int(win.text)) != win.text:
		return false
	if loss.text != "" and str(int(loss.text)) != loss.text:
		return false
	return true

func getWin() -> int:
	return int(win.text)

func getLoss() -> int:
	return int(loss.text)

func _on_text_changed(new_text):
	emit_signal("valueChanged")
