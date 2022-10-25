extends Control

onready var checkbox: CheckBox = $CheckBox
onready var roundContainer: VBoxContainer = $ScrollContainer/Rounds

var selected: bool = false
var level: int = -1

signal selected

func _ready():
	checkbox.pressed = selected

func setSelected(what: bool) -> void:
	selected = what
	if checkbox != null:
		checkbox.pressed = what

func setLevel(newLevel: int) -> void:
	assert (level == -1, "Can't change this on the fly")
	level = newLevel

func addRound(newRound: Control) -> void:
	roundContainer.add_child(newRound)

func _on_CheckBox_toggled(buttonPressed):
	if not buttonPressed:
		checkbox.pressed = true
		return
	emit_signal("selected", level)
