extends "res://subscenes/broadcast/round_display.gd"

func _ready() -> void:
	if roundRes != null:
		displayResData()

func attachResource(newRes: RoundResource):
	if not newRes is ForwardRound:
		printerr("This UI is for displaying forwarded players only.")
		return
	super.attachResource(newRes)
