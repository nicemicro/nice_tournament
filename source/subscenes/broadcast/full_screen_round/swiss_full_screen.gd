extends "res://subscenes/broadcast/full_screen_round/round_full_screen.gd"

onready var leftPlayerCol: VBoxContainer = $PanelContainer/Main/Container/Columns/PlayersLeft
onready var rightPlayerCol: VBoxContainer = $PanelContainer/Main/Container/Columns/PlayersRight
onready var mapPool: VBoxContainer = $PanelContainer/Main/Container/Columns/MapPool

func _ready() -> void:
	if roundRes != null:
		displayResData()

func attachResource(newRes: RoundResource):
	if not newRes is SwissRound:
		printerr("This UI is for displaying Swiss Rounds only.")
		return
	.attachResource(newRes)

func displayResData():
	for mapRes in roundRes.mapPool:
		var newLabel: Label = Label.new()
		newLabel.text = (mapRes.name)
		newLabel.align = Label.ALIGN_CENTER
		newLabel.size_flags_horizontal = SIZE_SHRINK_CENTER
		mapPool.add_child(newLabel)
	if roundRes.isStarted():
		var index: int = 0
		for grouping in roundRes.getGroupings():
			var newScene = load(groupDisplayPath)
			var newNode = newScene.instance()
			var container: VBoxContainer
			if index % 2 == 0:
				container = leftPlayerCol
			else:
				container = rightPlayerCol
			newNode.addGroup(grouping)
			container.add_child(newNode)
			var newSeparator: HSeparator = HSeparator.new()
			newSeparator.rect_min_size = Vector2(0, 5)
			container.add_child(newSeparator)
			index += 1
		return
	for index in roundRes.input / 2:
		var newScene = load(groupDisplayPath)
		var newNode = newScene.instance()
		var container: VBoxContainer
		if index % 2 == 0:
			container = leftPlayerCol
		else:
			container = rightPlayerCol
		newNode.addGroup([{}, {}])
		container.add_child(newNode)
		var newSeparator: HSeparator = HSeparator.new()
		newSeparator.rect_min_size = Vector2(0, 5)
		container.add_child(newSeparator)
