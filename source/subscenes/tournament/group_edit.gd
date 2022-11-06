extends "res://subscenes/tournament/round_edit_base.gd"

onready var groupSizeInp: LineEdit = $GroupSize/GroupSizeInput
onready var groupNumInp: LineEdit = $GroupNum/GroupNumInput
onready var neededWins: LineEdit = $NeededWins/WinInput
onready var availableList: PopupMenu = $AvailableMaps
onready var addedList: VBoxContainer = $MapPool

var availableMaps: Array

const mapDisplayScenePath: String = "res://subscenes/tournament/map_in_pool_display.tscn"

func _ready():
	._ready()
	playerNumberChange()

func attachResource(newRoundRes: RoundResource) -> void:
	if not newRoundRes is GroupRound:
		assert(false, "This UI is for seed rounds only.")
		return
	.attachResource(newRoundRes)

func _on_GroupSizeInput_text_changed(new_text):
	if str(int(new_text)) != new_text:
		groupSizeInp.text = ""
		roundRes.groupSize = 3
	else:
		roundRes.groupSize = int(new_text)
		groupSizeInp.text = str(roundRes.groupSize)
	playerNumberChange()

func _on_GroupNumInput_text_changed(new_text):
	if str(int(new_text)) != new_text:
		groupNumInp.text = ""
		roundRes.groupNum = 1
	else:
		roundRes.groupNum = int(new_text)
		groupNumInp.text = str(roundRes.groupNum)
	playerNumberChange()

func _on_WinInput_text_changed(new_text):
	if str(int(new_text)) != new_text:
		neededWins.text = ""
		roundRes.neededWins = 1
		return
	roundRes.neededWins = int(new_text)
	neededWins.text = str(roundRes.neededWins)

func _on_MapChoice_pressed():
	availableList.clear()
	availableMaps = []
	for mapRes in Global.maps.values():
		if mapRes in roundRes.mapPool:
			continue
		availableList.add_item(mapRes.name)
		availableMaps.append(mapRes)
	availableList.show()

func _on_AvailableMaps_id_pressed(id):
	roundRes.addMap(availableMaps[id])
	var newScene: PackedScene = preload(mapDisplayScenePath)
	var newNode: HBoxContainer = newScene.instance()
	newNode.attachResource(availableMaps[id])
	newNode.connect("action", self, "_on_mapAction_pressed")
	addedList.add_child(newNode)

func _on_mapAction_pressed(mapRes: MapResource, actionId: int) -> void:
	var mapIndex: int = roundRes.mapPool.find(mapRes)
	var nodeToActOn: Node = addedList.get_child(mapIndex)
	if actionId == 2:
		# Delete
		roundRes.removeMap(mapRes)
		nodeToActOn.queue_free()
		return
	var newPos: int
	if actionId == 0:
		# Move up
		if mapIndex == 0:
			return
		newPos = mapIndex - 1
	if actionId == 1:
		# Move down
		if mapIndex == len(roundRes.mapPool) - 1:
			return
		newPos = mapIndex + 1
	addedList.move_child(nodeToActOn, newPos)
	roundRes.moveMap(mapRes, newPos)
