extends "res://subscenes/broadcast/round_display.gd"

func _ready() -> void:
	if roundRes != null:
		displayResData()

func attachResource(newRes: RoundResource):
	if not newRes is SwissRound:
		printerr("This UI is for displaying Swiss rounds only.")
		return
	super.attachResource(newRes)

func _displayGroup(grouping: Array, newNode: Control) -> void:
	newNode.showPrevPoints(roundRes.virtualInputMult)
	super._displayGroup(grouping, newNode)
