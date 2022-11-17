extends "res://subscenes/broadcast/round_display.gd"

func _ready() -> void:
	if roundRes != null:
		displayResData()

func attachResource(newRes: RoundResource):
	if not newRes is SwissRound:
		printerr("This UI is for displaying Swiss rounds only.")
		return
	.attachResource(newRes)

func displayResData() -> void:
	if roundRes.isStarted():
		.displayResData()
		return
	for index in roundRes.input / 2:
		var newScene = load(groupDisplayPath)
		var newNode = newScene.instance()
		newNode.addGroup([{}, {}])
		detailContainer.add_child(newNode)
		var newSeparator: HSeparator = HSeparator.new()
		newSeparator.rect_min_size = Vector2(0, 5)
		detailContainer.add_child(newSeparator)
