extends VBoxContainer

onready var availableList: PopupMenu = $AvailableMaps
onready var addedList: VBoxContainer = $MapPool

var availableMaps: Array
var roundRes: RoundResource

const mapDisplayScenePath: String = "res://subscenes/tournament/map_in_pool_display.tscn"

func attachResource(newRoundRes: RoundResource) -> void:
	if roundRes != null:
		printerr("Resource already set")
		return
	roundRes = newRoundRes
	for mapRes in roundRes.mapPool:
		addMapNode(mapRes)

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
	addMapNode(availableMaps[id])

func addMapNode(mapRes: MapResource):
	var newScene: PackedScene = preload(mapDisplayScenePath)
	var newNode: HBoxContainer = newScene.instance()
	newNode.attachResource(mapRes)
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
