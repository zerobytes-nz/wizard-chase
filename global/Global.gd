#warning-ignore-all:unused_variable
extends Node2D

var default_player_lives := 3
var current_player_lives := default_player_lives

var current_level := 1  # continues
# actual levels that exist in the /levels folder
const MAX_LEVEL_MAPS := 5

var empty_coin_map_pos := [] as Array

var current_score := 00
# saw this on arcade donky kong sceenshot
var high_score := 7640

#var has_game_started := false

const chest_score_value := [500, 750, 1000, 1250]
var current_chest_score_index := 0

# https://strategywiki.org/wiki/Lock%27n%27Chase/Walkthrough
const misc_treasure_score_value := [200, 300, 500]
const misc_treasure_animation_color := [
	"4ba747", "ac3232", "ee8e2e", "b6cbcf", "9b1a0a", "4ba747", "da4e38", "da4e38", "5698cc", "97da3f", "da4e38"
]

var misc_treasure_get := []

# local
var timer
var is_player_alive
onready var player = get_tree().get_nodes_in_group("PLAYER")[0]

var is_enemies_speed_adjustment_per_level := false

signal state_changed
enum states {
	PLAYER_WAITING_TO_ENTER,
	ENTERED_MAZE,
	DIED_RESTARTING,
	LOADING_NEXT_LEVEL,
	GAME_OVER_RESTARTING,
	GAME_OVER_PLAYER_CAN_RESTART
}
var state: int = states.PLAYER_WAITING_TO_ENTER setget set_state

#this variable tells the enemies who to follow/find
var enemies_target:Node2D = null

func set_state(new_state: int) -> void:
	var old_state: int = state
	if new_state == old_state:
		return
	if new_state == null:
		breakpoint
	state = new_state
	emit_signal("state_changed", old_state, new_state)


func _ready():
	Global.enemies_target = get_tree().get_nodes_in_group("PLAYER")[0]
	set_state(states.PLAYER_WAITING_TO_ENTER)
	init()
	connect("state_changed", self, "on_state_changed")
	connect("state_changed", $"/root/Game".find_node_by_name("Treasure"), "on_state_changed")
	ready_power_ui()

func on_state_changed(from: int, to: int) -> void:
	if from == states.GAME_OVER_PLAYER_CAN_RESTART and to == states.PLAYER_WAITING_TO_ENTER:
		$"/root/Game/Audio/GameStartMusic".play()

	if to == states.ENTERED_MAZE and $"/root/Game/Audio/GameStartMusic".playing == true:
		$"/root/Game/Audio/GameStartMusic/GameStartMusicTween".fade_music_out($"/root/Game/Audio/GameStartMusic")


func init() -> void:
	timer = null
	is_player_alive = true
	#is_loading_next_level = false
	empty_coin_map_pos = []
	current_chest_score_index = 0
	current_player_lives = default_player_lives

	#self.set_state(states.ENTERED_MAZE)
	#has_game_started = false
	current_score = 00
	if $"/root/Game/Interface/UI/ScoreLabel" != null:
		$"/root/Game/Interface/UI/ScoreLabel".update_score(0)

	misc_treasure_get = []
	for i in $"/root/Game/World/Level/Treasure".MAX_LEVEL_MISC_TREASURE:
		misc_treasure_get.append(false)

	$"/root/Game/Interface/UI/HBoxContainer/UILives".reset_ui_lives()
	$"/root/Game/Interface/UI/HBoxContainer/UIInventory".hide_all()

	is_enemies_speed_adjustment_per_level = false
	var game_music_start := $"/root/Game/Audio/GameStartMusic" as AudioStreamPlayer
	game_music_start.volume_db = -20
	game_music_start.play()

signal player_died

func player_dies() -> void:
	set_state(states.DIED_RESTARTING)
	is_player_alive = false
	current_player_lives -= 1
	emit_signal("player_died")
	$"/root/Game/Audio/PlayerDieSound".play()

	if current_player_lives == 0:
		timer = Timer.new()
		timer.name = "start_game_over"
		self.add_child(timer)
		timer.set_wait_time(.5)
		timer.connect("timeout", self, "start_game_over")
		timer.set_one_shot(true)
		timer.start()
	else:
		$"/root/Game/Interface/UI/HBoxContainer/UILives".reset_ui_lives()

		timer = Timer.new()
		timer.name = "reset_level"
		self.add_child(timer)
		timer.set_wait_time(1)
		timer.connect("timeout", self, "reset_level")
		timer.set_one_shot(true)
		timer.start()
	
	


func reset_level() -> void:
	var map_level := _get_map_level()
	var level_scene_path = get_level_scene_path(map_level)
	$"/root/Game/Interface/SceneTransitionRect".transition_to(level_scene_path)
	set_state(states.PLAYER_WAITING_TO_ENTER)


func start_game_over() -> void:
	current_level = 1
	var map_level := _get_map_level()
	var level_scene_path = get_level_scene_path(map_level)

	$"/root/Game/World/GameOverCanvasModulate".start_game_over()
	restore_powerups()
	

	#init()
	#set_state(states.PLAYER_WAITING_TO_ENTER)


func get_misc_treasure() -> void:
	var misc_treasue_index := get_misc_treasure_index_for_level()

	misc_treasure_get[misc_treasue_index] = true
	var ui_node = $"/root/Game/Interface/UI/HBoxContainer/UIInventory".get_child(misc_treasue_index) as TextureRect
	if ui_node:
		ui_node.visible = true


func debug_get_misc_treasure(treasure_index : int) -> void:
	var misc_treasue_index := treasure_index

	misc_treasure_get[misc_treasue_index] = true
	var ui_node = $"/root/Game/Interface/UI/HBoxContainer/UIInventory".get_child(misc_treasue_index) as TextureRect
	if ui_node:
		ui_node.visible = true

func has_player_got_misc_treasure() -> bool:
	return misc_treasure_get[get_misc_treasure_index_for_level()]


func get_misc_treasure_index_for_level() -> int:
	var treasure = $"/root/Game".find_node_by_name("Treasure")
	if current_level < treasure.MAX_LEVEL_MISC_TREASURE:
		return current_level - 1
	else:
		return treasure.MAX_LEVEL_MISC_TREASURE - 1


func load_next_level(check_for_total_coins: bool) -> void:
	set_state(states.LOADING_NEXT_LEVEL)
	#if not is_loading_next_level:

	var treasure = $"/root/Game".find_node_by_name("Treasure")

	# TODO Remove is debug on?
	if check_for_total_coins:
		# load each time
		if treasure.get_total_coins_left() != 0:
			return

	#is_loading_next_level = true
	current_level += 1

	# reset last treasure slot to be false
	misc_treasure_get[treasure.MAX_LEVEL_MISC_TREASURE - 1] = false

	# level only
	empty_coin_map_pos = []
	$"/root/Game/World/Level/EnemyAI/EnemyFiend".disable_chase_state()
	$"/root/Game/World/Level/EnemyAI/EnemyLizardMan".disable_chase_state()
	$"/root/Game/World/Level/EnemyAI/EnemySlime".disable_chase_state()
	is_enemies_speed_adjustment_per_level = false

	$"/root/Game/Audio/NextLevelSound".play()

	var map_level := _get_map_level()
	var level_scene_path = get_level_scene_path(map_level)
	$"/root/Game/Interface/SceneTransitionRect".transition_to(level_scene_path)

	current_chest_score_index = 0
	#has_game_started = false

	return


func _get_map_level() -> int:
	var map_level := current_level % MAX_LEVEL_MAPS
	return MAX_LEVEL_MAPS if map_level == 0 else map_level


func get_level_scene_path(level: int) -> String:
	return "res://levels/Level_" + str(level) + ".tscn"




# ===========   PowerUPS ============

onready var ui_power1:UIPower = get_tree().get_nodes_in_group("UIPOWER")[0]
onready var ui_power2:UIPower = get_tree().get_nodes_in_group("UIPOWER")[1]
onready var ui_power3:UIPower = get_tree().get_nodes_in_group("UIPOWER")[2]

const POWER_IDS := {
	"tm" : {
		ui_texture = preload("res://ui/powerups/TurnMistSpell.webp")
	},
	"tp01" : {
		ui_texture = preload("res://ui/powerups/TeleportSpell.webp")
	},
	"tp" : {
		ui_texture = preload("res://ui/powerups/trapPlacementSpell.webp")
	},
	"sb" : {
		ui_texture = preload("res://ui/powerups/SpeedBoostSpell.webp")
	},
	"fe" : {
		ui_texture = preload("res://ui/powerups/FreezeEnemiesSpell.webp")
	},
	"dw" : {
		ui_texture = preload("res://ui/powerups/DecoyWizardSpell.webp")
	}
}

func ready_power_ui() -> void:
	
	ui_power1.visible = false
	ui_power2.visible = false
	ui_power3.visible = false
	
	print(ui_power1.name)
	print(ui_power2.name)
	print(ui_power3.name)
	
	pass

func _input(event):
	if event is InputEventKey:
		_check_power(1)
		_check_power(2)
		_check_power(3)
	pass

func _check_power(index:int) -> void:
	if Input.is_action_just_pressed("use_power_%s" % index):
		if is_player_alive == false: return
		if state != states.ENTERED_MAZE: return
		if powers["slot%s" % index] is Powerup:
			var power:Powerup = powers["slot%s" % index]
			power.use()
#			if power.availability <= 0:
#				powers["slot%s" % index].block()
	pass

var powers:Dictionary = {
	slot1 = {},
	slot2 = {},
	slot3 = {}
}

var last_powers_received_amount := {}

func add_power(power:Powerup) -> void:
	if powers.slot1 is Dictionary:
		powers.slot1 = power
		ui_power1.activate(power)
		last_powers_received_amount[1] = power.availability
		return
	if powers.slot2 is Dictionary:
		powers.slot2 = power
		ui_power2.activate(power)
		last_powers_received_amount[2] = power.availability
		return
	if powers.slot3 is Dictionary:
		powers.slot3 = power
		ui_power3.activate(power)
		last_powers_received_amount[3] = power.availability
		return
	pass

func restore_powerups() -> void:
	for id in last_powers_received_amount.keys():
		powers["slot%s" % id].set_availability(last_powers_received_amount[id])
		pass
	pass

var turn_mist_activated:bool = false
#func _init(itemID:String, description:String, duration:float,cooldown:float,availability:float):
func debug_get_turn_mist() -> void:
	var turn_mist := TurnMist.new()
	turn_mist.itemID = "tm"
	turn_mist.duration = 3.0
	turn_mist.cooldown = 5.0
	turn_mist.availability = 3
	add_power(turn_mist)
	pass
	
func debug_get_decoy_wizard() -> void:
	var decoy_wizard := DecoyWizard.new()
	decoy_wizard.itemID = "dw"
	decoy_wizard.duration = 6.0
	decoy_wizard.cooldown = 5.0
	decoy_wizard.availability = 3
	add_power(decoy_wizard)
	pass
	
func debug_get_teleport_spell() -> void:
	var teleport := Teleport.new()
	teleport.itemID = "tp01"
	teleport.cooldown = 5.0
	teleport.availability = 3
	add_power(teleport)
	pass
	
func debug_get_trap_placement() -> void:
	var trap := Trap.new()
	trap.itemID = "tp"
	trap.duration = 3.0
	trap.cooldown = 7.0
	trap.availability = 3
	add_power(trap)
	pass
	
func debug_get_freeze() -> void:
	var freeze := Freeze.new()
	freeze.itemID = "fe"
	freeze.cooldown = 5.0
	freeze.availability = 3
	freeze.duration = 4.0
	add_power(freeze)
	pass
	
func debug_get_speed() -> void:
	var speedb := SpeedBoost.new()
	speedb.itemID = "sb"
	speedb.cooldown = 5.0
	speedb.availability = 3
	speedb.duration = 4.0
	add_power(speedb)
	pass


