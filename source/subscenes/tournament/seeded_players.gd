extends "res://subscenes/tournament/round_edit_base.gd"

@onready var availableList: PopupMenu = $AvailablePlayers
@onready var addedList: VBoxContainer = $PlayerList

const playerDisplayScenePath: String = "res://subscenes/tournament/seeded_player_display.tscn"

var availabePlayers: Array = []

func _ready():
	mapPoolEditor.visible = false
	if roundRes != null:
		for playerRes in roundRes.getSeededPlayers():
			addPlayerNode(playerRes)

func attachResource(newRoundRes: RoundResource) -> void:
	if not newRoundRes is SeedRound:
		assert(false, "This UI is for seed rounds only.")
		return
	super.attachResource(newRoundRes)
	if addedList != null:
		for playerRes in roundRes.getSeededPlayers():
			addPlayerNode(playerRes)

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
	addPlayerNode(availabePlayers[id])
	playerNumberChange()
	refreshAvailabePlayers()

func addPlayerNode(playerRes: PlayerResource) -> void:
	var newScene: PackedScene = preload(playerDisplayScenePath)
	var newNode: HBoxContainer = newScene.instantiate()
	newNode.attachResource(playerRes)
	newNode.connect("action", Callable(self, "_on_playerAction_pressed"))
	addedList.add_child(newNode)

func _on_playerAction_pressed(playerRes: PlayerResource, actionId: int) -> void:
	var playerIndex: int = roundRes.getSeededPlayers().find(playerRes)
	var nodeToActOn: Node = addedList.get_child(playerIndex)
	if actionId == 2:
		# Delete
		roundRes.removePlayer(playerRes)
		nodeToActOn.queue_free()
		playerNumberChange()
		return
	var newPos: int
	if actionId == 0:
		# Move up
		if playerIndex == 0:
			return
		newPos = playerIndex - 1
	if actionId == 1:
		# Move down
		if playerIndex == len(roundRes.getSeededPlayers()) - 1:
			return
		newPos = playerIndex + 1
	addedList.move_child(nodeToActOn, newPos)
	roundRes.movePlayer(playerRes, newPos)
