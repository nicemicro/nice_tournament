extends "res://subscenes/broadcast/round_display.gd"

func _ready() -> void:
	if roundRes != null:
		displayResData()

func attachResource(newRes: RoundResource):
	if not newRes is SeedRound:
		printerr("This UI is for displaying Seed rounds only.")
		return
	.attachResource(newRes)

func displayResData():
	for player in roundRes.getOutPlayerList():
		var newLabel: Label = Label.new()
		newLabel.text = (
			player.name + " [" +
			player.getRaceName() + "]"
		)
		detailContainer.add_child(newLabel)
