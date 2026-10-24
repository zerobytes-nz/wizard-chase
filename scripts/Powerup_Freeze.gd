extends Powerup
class_name Freeze

const FREEZE_COLOR := Color("24bbde")
var data := {}

func _action() -> void:
	var enemies = Global.get_tree().get_nodes_in_group("ENEMY")
	
	for enemy in enemies:
		var sprite:AnimatedSprite = enemy.get_node("AnimatedSprite")
		sprite.modulate = FREEZE_COLOR
		sprite.playing = false
		data[enemy.name] = enemy.speed
		enemy.speed = 0.0
		pass
	
	
	var timer = Global.get_tree().create_timer(duration,false)
	timer.connect("timeout",self,"_on_timeout")
	
	pass

func _on_timeout() -> void:
	var enemies = Global.get_tree().get_nodes_in_group("ENEMY")
	
	for enemy in enemies:
		var sprite:AnimatedSprite = enemy.get_node("AnimatedSprite")
		sprite.modulate = Color.white
		sprite.playing = true
		enemy.speed = data[enemy.name]
		pass
	pass

func _cooldown_finished() -> void:
	
	pass

func _on_player_died() -> void:
	
	pass
