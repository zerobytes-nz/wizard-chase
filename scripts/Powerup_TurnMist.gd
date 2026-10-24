extends Powerup
class_name TurnMist

var player_sprite:AnimatedSprite = null
var died:bool = false

func _action() -> void:
	player_sprite = Global.get_tree().get_nodes_in_group("PLAYER")[0].get_node("AnimatedSprite")
		
	Global.turn_mist_activated = true
	
	player_sprite.modulate.a = 0.4
	
	pass

func _cooldown_finished() -> void:
	if died: 
		died = false
		return
	Global.turn_mist_activated = false
	player_sprite.modulate.a = 1.0
	pass

func _on_player_died() -> void:
	if Global.turn_mist_activated == false: return
	died = true
	player_sprite.modulate.a = 1.0	
	Global.turn_mist_activated = false
	pass
