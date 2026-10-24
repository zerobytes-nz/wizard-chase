extends Enemy
class_name FakeWizard

const FAKE: Color = Color("#ffff")

export var is_enabled := true

onready var fx_destroy = $FXDestroy
var life_time:float

func _enter_tree():
	remove_from_group("ENEMY")
	pass

func _ready():
	set_process(is_enabled)
	set_physics_process(false)
	# slower than other enemies
	var player = get_tree().get_nodes_in_group("PLAYER")[0]
	speed = player.speed
	fx_destroy.connect("finished",self,"_on_fx_finished")
	

func _on_fx_finished() -> void:
	queue_free()
	pass

func _physics_process(delta:float) -> void:
	life_time -= delta
	#if collides with any enemie then destroy this
	if get_overlapping_areas().size() > 0 or life_time < 0.0:
		set_process(false)
		set_physics_process(false)
		$AnimatedSprite.visible = false
		#set all enemies target back to player
		Global.enemies_target = get_tree().get_nodes_in_group("PLAYER")[0]
		fx_destroy.emitting = true
	
	pass

func change_states():
	if state is IdleState or state is ClydeState:
		change_state(self, EnemyStateEnum.CLYDE, 99)
	else:
		change_state(self, EnemyStateEnum.CLYDE, 99)


func _get_enemy_color() -> Color:
	return FAKE
