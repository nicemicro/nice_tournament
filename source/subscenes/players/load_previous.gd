extends HBoxContainer

@onready var raceOption = $Button
@onready var label = $Label

var _labelText: String = ""
var _id: int

signal itemSelected

func _ready():
	label.text = _labelText

func setLabel(text: String) -> void:
	_labelText = text
	if label == null:
		return
	label.text = text

func setId(newId: int) -> void:
	_id = newId

func _on_button_pressed():
	emit_signal("itemSelected", _id)
