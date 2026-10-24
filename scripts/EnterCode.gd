extends TextureButton

onready var enter_code_dialog = $EnterCodeDialog
onready var le_code = $EnterCodeDialog/le_code
onready var bt_send = $EnterCodeDialog/bt_send

func _ready():
	bt_send.connect("pressed",self,"_on_send_pressed")
	API.connect("done_request",self,"_on_fetched")
	enter_code_dialog.connect("popup_hide",self,"_on_hide")

func _pressed():
	
	enter_code_dialog.popup_centered()
	get_tree().paused = true
	
	pass
onready var api = get_tree().root.get_node("API")

func _on_send_pressed() -> void:
	print("sent request")
	bt_send.disabled = true
	api.request(le_code.text)

	pass

func _on_fetched(data:Dictionary) -> void:
	
	if data == null: close()
	
	if data.message == "User Items":
		for result in data.results:
			create_power(result.itemData)
		close()
		pass
	
	bt_send.disabled = false
	pass

func close() -> void:
	enter_code_dialog.hide()
	get_tree().paused = false	
	
func _on_hide() -> void:
	get_tree().paused = false
	pass
	
func create_power(data:Dictionary) -> void:
	print("creating power for: ", data.title)
	print(data)
	
	var itemID:String = data.itemId
	
	var power : Powerup = null
	
	if itemID == "tm": power = TurnMist.new()
	elif itemID == "tp01":power = Teleport.new()
	elif itemID == "tp": power = Trap.new()
	elif itemID == "fe": power = Freeze.new()
	elif itemID == "dw": power = DecoyWizard.new()
	elif itemID == "sb": 
		power = SpeedBoost.new()
		(power as SpeedBoost).speed_multiplier = float(data["Speed Multiplier"])
	else: 
		push_error("No power with itemID: %s, title: %s" % [itemID, data.title])
		return
	
	power.availability = int(data.Availability)
	power.cooldown = float(data.Cooldown)
	if (data.has("Duration")):
		power.duration = float(data.Duration)
	else: power.duration = 0.0
	power.itemID = itemID
	
	Global.add_power(power)
	
	pass

