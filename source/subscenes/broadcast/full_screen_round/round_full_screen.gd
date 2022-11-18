extends HBoxContainer

onready var screenContainer: VBoxContainer = $PanelContainer/Main
onready var matchContainer: MarginContainer = $PanelContainer/MatchContainer
onready var mainContainer: MarginContainer = $PanelContainer/Main/Container

var roundRes: RoundResource
var matchOverlayOn: bool = false

const groupDisplayPath: String = "res://subscenes/broadcast/single_group_display.tscn"

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

func _createGroupDisplayScene() -> VBoxContainer:
	var newScene = preload(groupDisplayPath)
	var newNode: VBoxContainer = newScene.instance()
	newNode.connect("openGroup", self, "_openGroupPlayWindow")
	return newNode

func _openGroupPlayWindow(groupData: Array) -> void:
	screenContainer.visible = false
	matchContainer.visible = true
	matchOverlayOn = true

func _on_CloseButton_pressed() -> void:
	if matchOverlayOn:
		screenContainer.visible = true
		matchContainer.visible = false
		return
	emit_signal("closeScreen")
