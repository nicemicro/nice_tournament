extends VBoxContainer

onready var playerNumber: LineEdit = $HBoxContainer/PlayerCounter
onready var availableList: PopupMenu = $AvailablePlayers
onready var addedList: VBoxContainer = $PlayerList

const playerDisplayScenePath: String = "res://subscenes/tournament/seeded_player_display.tscn"

var roundRes: SeedRound
var availabePlayers: Array = []

func _ready():
	pass

func attachResource(newRoundRes: SeedRound) -> void:
	if roundRes != null:
		printerr("Resource already set")
		return
	roundRes = newRoundRes

func refreshAvailabePlayers() -> void:
	availableList.clear()
	availabePlayers = []
	for playerRes in Global.players.values():
		if Tournament.isPlayerSeeded(playerRes):
			continue
		availableList.add_item(playerRes.name)
		availabePlayers.append(playerRes)

func _on_Button_mouse_entered() -> void:
	refreshAvailabePlayers()

func _on_Button_pressed() -> void:
	availableList.show()

func _on_AvailablePlayers_id_pressed(id: int) -> void:
	roundRes.addPlayer(availabePlayers[id])
	var newScene: PackedScene = preload(playerDisplayScenePath)
	var newNode: HBoxContainer = newScene.instance()
	newNode.attachResource(availabePlayers[id])
	newNode.connect("action", self, "_on_playerAction_pressed")
	addedList.add_child(newNode)
	playerNumber.text = str(roundRes.output)
	refreshAvailabePlayers()

func _on_playerAction_pressed(playerRes: PlayerResource, actionId: int) -> void:
	var playerIndex: int = roundRes.seededPlayers.find(playerRes)
	var nodeToActOn: Node = addedList.get_child(playerIndex)
	if actionId == 2:
		# Delete
		roundRes.removePlayer(playerRes)
		nodeToActOn.queue_free()
		return
	var newPos: int
	if actionId == 0:
		# Move up
		if playerIndex == 0:
			return
		newPos = playerIndex - 1
	if actionId == 1:
		# Move down
		if playerIndex == len(roundRes.seededPlayers) - 1:
			return
		newPos = playerIndex + 1
	addedList.move_child(nodeToActOn, newPos)
	roundRes.movePlayer(playerRes, newPos)
