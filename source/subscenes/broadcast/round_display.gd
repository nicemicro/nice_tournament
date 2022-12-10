extends PanelContainer

onready var titleLabel: Label = $Main/Title
onready var detailContainer: VBoxContainer = $Main/Container
onready var openButton: TextureButton = $Main/OpenButton

const groupDisplayPath: String = "res://subscenes/broadcast/single_group_display.tscn"

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
	for grouping in roundRes.getGroupings():
		var newScene = preload(groupDisplayPath)
		var newNode = newScene.instance()
		_displayGroup(grouping, newNode)

func _displayGroup(grouping: Array, newNode: Control) -> void:
	var levelNum: int = Tournament.getLevelNum(roundRes)
	newNode.setUp(grouping, levelNum)
	detailContainer.add_child(newNode)

func _on_OpenButton_pressed() -> void:
	emit_signal("openFullScreen", roundRes)
