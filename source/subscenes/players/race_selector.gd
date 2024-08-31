extends HBoxContainer

@onready var raceOption = $OptionButton
@onready var label = $Label

var _labelText: String = ""

signal itemSelected

# Called when the node enters the scene tree for the first time.
func _ready():
	for race in Global.RaceName:
		raceOption.add_item(Global.RaceName[race], int(race))
	label.text = _labelText

func setLabel(text: String) -> void:
	_labelText = text
	if label == null:
		return
	label.text = text

func _on_OptionButton_item_selected(index):
	emit_signal("itemSelected", index)

func setSelection(index: int):
	raceOption.select(index)

func getSelection() -> int:
	return raceOption.selected
