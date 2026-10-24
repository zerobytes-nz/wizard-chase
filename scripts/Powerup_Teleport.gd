extends Powerup
class_name Teleport

func _action() -> void:
	var dungeon:Dungeon = Global.get_tree().get_nodes_in_group("DUNGEON")[0]
	var enemies:Array = Global.get_tree().get_nodes_in_group("ENEMY")
	var player:Player = Global.get_tree().get_nodes_in_group("PLAYER")[0]
	#get all possible positions in dungeon - ID = 0 means ground (walkable)
	var cells := dungeon.get_used_cells_by_id(0)
	#randomize array (to not always get same result)
	cells.shuffle()
	#get all enemies position (avoid spawning near enemies
	var enemies_pos := PoolVector2Array()
	for enemy in enemies:
		enemies_pos.append(enemy.global_position)
	
	#check which cell is most far from all enemies
	var data := {}
	for cell in cells:
		var pos := dungeon.map_to_world(cell)
		var median_pos:float
		
		for enemy_pos in enemies_pos:
			median_pos += ( abs(enemy_pos.x - pos.x) + abs(enemy_pos.y - pos.y) )
			pass
			
		median_pos /= enemies.size()
		
		#store into data all medians
		data[int(median_pos)] = pos
		pass
	
	#now get from data which position is the most far from all enemies
	var best_cell:int = -INF
	while(true):
		for key in data.keys():
			if key > best_cell:
				best_cell = key
		
		var target := dungeon.world_to_map(data[best_cell])
		if not dungeon.is_cell_tile_navigable(target):
			data.erase(best_cell)
			best_cell = -INF
			continue
		
		break
	
	#teleport player
	player.direction = Vector2.ZERO
	var target_position :Vector2= data[best_cell]
	player.global_position = target_position
	
	pass

func _cooldown_finished() -> void:
	
	pass

func _on_player_died() -> void:
	
	pass
