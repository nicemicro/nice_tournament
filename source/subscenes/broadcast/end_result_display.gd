extends "res://subscenes/broadcast/round_display.gd"

func _ready() -> void:
	if roundRes != null:
		displayResData()

func attachResource(newRes: RoundResource):
	if not newRes is EndResultRound:
		printerr("This UI is for displaying end results only.")
		return
	.attachResource(newRes)

func displayResData():
	var place: int = 0
	for player in roundRes.getFinalOrder():
		place += 1
		var newLabel: Label = Label.new()
		if player is PlayerResource:
			newLabel.text = str(place) + ". " + player.name
		else:
			newLabel.text = str(place) + ". " + player
		detailContainer.add_child(newLabel)
