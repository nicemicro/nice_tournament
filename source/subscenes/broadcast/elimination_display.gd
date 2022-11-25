extends "res://subscenes/broadcast/round_display.gd"

func _ready() -> void:
	if roundRes != null:
		displayResData()

func attachResource(newRes: RoundResource):
	if not newRes is EliminationRound:
		printerr("This UI is for displaying Elimination rounds only.")
		return
	.attachResource(newRes)
