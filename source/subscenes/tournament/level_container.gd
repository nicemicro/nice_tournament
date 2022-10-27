extends Control

onready var checkbox: CheckBox = $CheckBox
onready var roundContainer: VBoxContainer = $ScrollContainer/Rounds

var selected: bool = false
var level: int = -1 setget setLevel, getLevel

signal selected

func _ready():
	checkbox.pressed = selected

func setSelected(what: bool) -> void:
	selected = what
	if checkbox != null:
		checkbox.set_pressed_no_signal(what)

func setLevel(newLevel: int) -> void:
	assert (level == -1, "Can't change this on the fly")
	level = newLevel

func getLevel() -> int:
	return level

func addRound(newRound: Control) -> void:
	roundContainer.add_child(newRound)

func _on_CheckBox_pressed():
	if not checkbox.pressed:
		setSelected(true)
	else:
		selected = false
		emit_signal("selected", level)
