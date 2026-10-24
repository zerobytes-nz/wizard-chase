extends Powerup
class_name SpeedBoost

var record_speed:float = -1
var speed_multiplier:float = 2.0

func _action() -> void:
	var player :Player = Global.get_tree().get_nodes_in_group("PLAYER")[0]
	player.get_node("AnimatedSprite").modulate = Color("f6771b")
	
	if record_speed < 0:
		record_speed = player.speed
	
	player.speed *= speed_multiplier
	
	var timer = Global.get_tree().create_timer(duration,false)
	timer.connect("timeout",self,"_on_timeout")
	
	pass

func _on_timeout() -> void:
	var player :Player = Global.get_tree().get_nodes_in_group("PLAYER")[0]
	player.get_node("AnimatedSprite").modulate = Color.white
	player.speed = record_speed
	record_speed = -1.0
	pass

func _cooldown_finished() -> void:
	
	pass

func _on_player_died() -> void:
	if record_speed < 0.1: return
	var player :Player = Global.get_tree().get_nodes_in_group("PLAYER")[0]
	player.speed = record_speed
	pass
