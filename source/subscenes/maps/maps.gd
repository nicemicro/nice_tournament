extends Control

onready var playerContainer: GridContainer = $Container

var playerAddWindow: WindowDialog = null

const addMapScenePath: String = "res://subscenes/maps/add_map.tscn"
const mapInfoScenePath: String = "res://subscenes/maps/map_info.tscn"

signal backPressed

func addAllMaps():
	for mapId in Global.maps:
		displayMap(Global.maps[mapId])

func _on_Back_pressed():
	self.visible = false
	emit_signal("backPressed")

func _on_AddNew_pressed():
	var newScene = preload(addMapScenePath)
	var mapAddWindow = newScene.instance()
	mapAddWindow.connect("popup_hide", self, "removeAddPlayerNode")
	mapAddWindow.connect("mapCreated", self, "saveMap")
	add_child(mapAddWindow)
	mapAddWindow.show()

func removeAddPlayerNode():
	playerAddWindow.queue_free()
	playerAddWindow = null

func saveMap(newMap: MapResource):
	Global.registerNewMap(newMap)
	displayMap(newMap)

func displayMap(mapRes: MapResource):
	var newScene = preload(mapInfoScenePath)
	var mapInfo = newScene.instance()
	mapInfo.setUpPlayer(mapRes)
	playerContainer.add_child(mapInfo)
