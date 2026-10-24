extends Area2D
class_name TrapObject

var power:Powerup = null
var duration:float = 10.0
var enemy_speed:float = 0.0
var target_enemy:Enemy = null

func _ready():
	set_process(false)
	

func configure(_power) -> void:
	power = _power
	duration = power.duration


func _on_Trap_area_entered(area):
	print(area)
	$CollisionShape2D.queue_free()
#	monitoring = false
	target_enemy = area
	stop_enemy()
	pass # Replace with function bod

func stop_enemy() -> void:
	enemy_speed = target_enemy.speed
	target_enemy.speed = 0.0
	target_enemy.set_process(false)
	target_enemy.set_physics_process(false)
	
	var timer := get_tree().create_timer(power.duration,false)
	timer.connect("timeout",self,"_on_timer_ends")
	set_process(true)
	pass

func _process(delta):
	duration -= delta
	$Sprite.modulate.a = remap(duration, 0, power.duration,0,1)
	$Sprite.scale.x = remap(duration, 0, power.duration,0,1)
	$Sprite.scale.y = remap(duration, 0, power.duration,0,1)
	if duration < 0.0:
		destroy()
	pass


func _on_timer_ends() -> void:
	destroy()

	pass

func destroy() -> void:
	target_enemy.speed = enemy_speed
	target_enemy.set_process(true)
	target_enemy.set_physics_process(true)
	queue_free()
	pass

# Function to remap a value from one range to another
func remap(value: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	# Calculate the remapped value
	return (value - in_min) / (in_max - in_min) * (out_max - out_min) + out_min
