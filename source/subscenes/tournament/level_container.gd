extends VBoxContainer

@onready var roundContainer: VBoxContainer = $ScrollContainer/Rounds
@onready var checkbox: CheckBox = $Footer/FooterBox/CheckBoxContainer/CheckBox
@onready var inputNumField: LineEdit = $Footer/FooterBox/InNum
@onready var outputNumField: LineEdit = $Footer/FooterBox/OutNum

var selected: bool = false
var level: int = -1: get = getLevel, set = setLevel

signal selected

func _ready():
	checkbox.button_pressed = selected

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
	newRound.connect("playerNumChange", Callable(self, "_on_playerNumChange"))
	roundContainer.add_child(newRound)

func setInputOutput(newInput: int, newOutput: int) -> void:
	inputNumField.text = str(newInput)
	outputNumField.text = str(newOutput)

func _on_CheckBox_pressed():
	if not checkbox.pressed:
		setSelected(true)
	else:
		selected = false
		emit_signal("selected", level)

func _on_playerNumChange() -> void:
	var counter: int = 0
	for roundRes in Tournament.rounds[level]:
		counter += roundRes.input
	inputNumField.text = str(counter)
	counter = 0
	for roundRes in Tournament.rounds[level]:
		counter += roundRes.output
	outputNumField.text = str(counter)
