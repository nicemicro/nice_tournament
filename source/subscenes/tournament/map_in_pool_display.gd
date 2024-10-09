extends HBoxContainer

@onready var nameLabel: Label = $MapName
@onready var actionMenuButton: MenuButton = $Action

var mapRes: MapResource

signal action

# Called when the node enters the scene tree for the first time.
func _ready():
	if mapRes != null:
		showPlayerDetails()
	var actionList = actionMenuButton.get_popup()
	actionList.id_pressed.connect(_on_ActionMenuPoint_pressed)

func attachResource(newRes: MapResource) -> void:
	if (mapRes != null):
		printerr("Resource already set")
		return
	mapRes = newRes
	if nameLabel != null:
		showPlayerDetails()
		
func showPlayerDetails() -> void:
	nameLabel.text = (
		mapRes.name
	)

func _on_ActionMenuPoint_pressed(id: int) -> void:
	emit_signal("action", mapRes, id)
