extends Powerup
class_name DecoyWizard

var ps_wizard := preload("res://enemy/fake_wizard/FakeWizard.tscn")


func _action() -> void:
	var player:Player = Global.get_tree().get_nodes_in_group("PLAYER")[0]
	var node:Node2D = Global.get_tree().get_nodes_in_group("ENEMY_AI")[0]
	var wizard:FakeWizard = ps_wizard.instance()
	node.add_child(wizard)
	wizard.global_position = player.global_position
	wizard.life_time = duration
	Global.enemies_target = wizard
	wizard.set_physics_process(true)
	
	pass

func _cooldown_finished() -> void:
	
	pass

#avoid bugs
func _on_player_died() -> void:
	var player:Player = Global.get_tree().get_nodes_in_group("PLAYER")[0]
	Global.enemies_target = player
	pass
