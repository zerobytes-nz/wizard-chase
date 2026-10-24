extends TextureRect
class_name UIPower


onready var lb_amt = $lb_amt
onready var progress_bar = $ProgressBar
onready var text = lb_amt.text

var target_power:Powerup = null
var cooldown_timer:float = 0.0
	

func activate(power:Powerup) -> void:
	power.connect("used",self,"_on_used")
	power.connect("ended",self,"_on_ended")
	
	target_power = power
	power.connect("availability_set",self,"_on_set_availability")
	progress_bar = get_node("ProgressBar")
	
	var _texture = Global.POWER_IDS[power.itemID].ui_texture
	texture = _texture
	
	lb_amt.text = text % power.availability
	
	progress_bar.max_value = power.cooldown
	
	modulate = Color.white
	
	visible = true
	pass

func _on_set_availability(power:Powerup) -> void:
	modulate = Color.white
	visible = true
	lb_amt.text = text % power.availability
	
	pass


func _process(delta):
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		progress_bar.value = cooldown_timer
		pass
	pass

func _on_used() -> void:
	cooldown_timer = target_power.cooldown
	progress_bar.value = progress_bar.max_value
	lb_amt.text = text % target_power.availability
	pass

func _on_ended() -> void:
#	visible = false
	modulate = Color.darkgray
	target_power = null
	pass
