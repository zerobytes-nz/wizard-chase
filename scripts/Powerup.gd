extends Reference
class_name Powerup

signal used
signal ended
signal availability_set

var itemID:String
var description:String

var duration:float
var cooldown:float = -1
var availability:int
var can_use:bool = true

var COLOR_LOCKED := Color.darkgray


func _init():
	Global.connect("player_died",self,"_on_player_died")

#func _init(itemID:String, description:String, duration:float,cooldown:float,availability:int):
#	self.itemID = itemID
#	self.description = description
#	self.duration = duration
#	self.cooldown = cooldown
#	self.availability = availability
#	self.can_use = true

#what this powerup does
func _action() -> void: assert(false, "you must implement me in extended class")

func set_availability(value:int) -> void:
	availability = value
	emit_signal("availability_set", self)
	pass

#called by the player
func use() -> void:
	if (availability <= 0 or not can_use): 
		
		return
	can_use = false
	_action()
	availability -= 1
	
	var timer :SceneTreeTimer = Global.get_tree().create_timer(cooldown,false)
	timer.connect("timeout",self, "_on_cooldown_finished")
	emit_signal("used")
	pass

func _on_cooldown_finished() -> void:
	_cooldown_finished()
	can_use = true
	
	if availability <= 0: emit_signal("ended")
	
	pass

#use this in extended classes to call another event if necessary
func _cooldown_finished() -> void: pass

func _on_player_died() -> void: assert(false, "implement _on_player_died")
