extends "res://subscenes/broadcast/round_display.gd"

@onready var orderButtonContainer: VBoxContainer = %OrderButtonContainer
@onready var mainContainer: VBoxContainer = %Container
@onready var orderedContainer: GridContainer = %OrderedContainer
@onready var orderButton: TextureButton = %OpenOrderedButton

func _ready() -> void:
	if roundRes != null:
		displayResData()

func displayResData() -> void:
	if roundRes.isOver() and roundRes.type == "swiss":
		orderButtonContainer.visible = true
		for headerText in ["Name", "Pts", "Gms", "Opp"]:
			var newLabel: Label = Label.new()
			newLabel.text = headerText
			orderedContainer.add_child(newLabel)
		var counter: int = 0
		for playerPoints in roundRes.sortPlayersByPoint(true, true):
			counter += 1
			var nameLabel: Label = Label.new()
			nameLabel.text = str(counter) + ". " + playerPoints["player"].name
			orderedContainer.add_child(nameLabel)
			for key in ["points", "gameNumber", "opponentPoints"]:
				var newLabel: Label = Label.new()
				newLabel.text = str(playerPoints[key])
				orderedContainer.add_child(newLabel)
	super.displayResData()

func attachResource(newRes: RoundResource):
	if not newRes is SwissRound:
		printerr("This UI is for displaying Swiss rounds only.")
		return
	super.attachResource(newRes)

func _displayGroup(grouping: Array, newNode: Control) -> void:
	newNode.showPrevPoints(roundRes.virtualInputMult)
	super._displayGroup(grouping, newNode)

func _on_open_ordered_button_pressed():
	orderedContainer.visible = !orderedContainer.visible
	mainContainer.visible = !mainContainer.visible
	orderButton.flip_v = !orderButton.flip_v
