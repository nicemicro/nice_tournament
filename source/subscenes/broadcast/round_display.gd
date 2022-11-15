extends PanelContainer

onready var titleLabel: Label = $Main/Title
onready var detailContainer: VBoxContainer = $Main/Container
onready var openButton: TextureButton = $Main/OpenButton

var roundRes: RoundResource

signal openFullScreen


func attachResource(newRes: RoundResource) -> void:
	if roundRes != null:
		printerr("Resource already set")
		return
	roundRes = newRes
	if detailContainer != null:
		displayResData()

func displayResData() -> void:
	pass

func _on_OpenButton_pressed() -> void:
	emit_signal("openFullScreen", roundRes)
