extends "res://subscenes/broadcast/round_display.gd"

func _ready() -> void:
	if roundRes != null:
		displayResData()

func attachResource(newRes: RoundResource):
	if not newRes is ForwardRound:
		printerr("This UI is for displaying forwarded players only.")
		return
	.attachResource(newRes)

func displayResData():
	if not roundRes.isOver():
		for index in range(roundRes.output):
			var newLabel: Label = Label.new()
			newLabel.text = "???"
			detailContainer.add_child(newLabel)
		return
	for player in roundRes.getOutPlayerList():
		var newLabel: Label = Label.new()
		newLabel.text = (
			player.name + " [" +
			player.getRaceName() + "]"
		)
		detailContainer.add_child(newLabel)
