extends HBoxContainer

onready var mainContainer: VBoxContainer =$PanelContainer/Main/Container

var roundRes: RoundResource

signal closeScreen

func attachResource(newRes: RoundResource) -> void:
	if roundRes != null:
		printerr("Resource already set")
		return
	roundRes = newRes
	if mainContainer != null:
		displayResData()

func displayResData() -> void:
	pass

func _on_CloseButton_pressed() -> void:
	emit_signal("closeScreen")
