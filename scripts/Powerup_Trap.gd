extends Powerup
class_name Trap

#the id of the tile representing the trap
const ps_trap := preload("res://powers/Trap.tscn")

func _action() -> void:
	var player:Player = Global.get_tree().get_nodes_in_group("PLAYER")[0]
	var trap = ps_trap.instance()
	trap.configure(self)
	player.get_parent().add_child(trap)
	trap.global_position = player.global_position
	pass

func _cooldown_finished() -> void:
	
	pass

func _on_player_died() -> void:
	
	pass
