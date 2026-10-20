extends Node

const SERVER_PORT = 8080
# Currently, this has to be set to Host computer's IP address
# 	and both computers must be on the same network
const SERVER_IP = "127.0.0.1"


# Scene that represents a multiplayer character
var multiplayer_scene = preload("res://multiplayer/MultiplayerPlayer.tscn")

var _players_spawn_node
var host_mode_enabled = false




func become_host():
	print("Starting host!")

	_players_spawn_node = get_tree().get_current_scene().get_node("Players")
	
	host_mode_enabled = true

	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	
	_remove_single_player()
	
	_add_player_to_game(1)



func join_as_player_2():
	print("Player 2 joining")

	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	
	multiplayer.multiplayer_peer = client_peer
	
	_remove_single_player()


func _add_player_to_game(id: int):
	print("Player %s joined the game!" % id)
	
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	_players_spawn_node.add_child(player_to_add, true)
	# The joiner's scene still has every brain and a zeroed score table.
	_sync_scores_to_peer.call_deferred(id)



func _del_player(id: int):
	print("Player %s left the game!" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
	



func _remove_single_player():
	print("Remove single player")
	var player_to_remove = get_tree().get_current_scene().get_node("Player")
	player_to_remove.queue_free()
	


#region Scoring
# Dictionary tracking player_id (int) -> score (int)
var player_scores: Dictionary = {}
# Absolute paths of brains the server has already awarded.
var collected_brain_paths: Array[NodePath] = []

# Signal to alert your UI layer when a score changes locally
signal score_updated(player_id: int, new_score: int)

# Server-only. Awards points once, then removes that brain on every peer.
func award_pickup(player_id: int, brain_path: NodePath, amount: int) -> void:
	if not multiplayer.is_server():
		return
	if collected_brain_paths.has(brain_path):
		return
	if get_node_or_null(brain_path) == null:
		return

	collected_brain_paths.append(brain_path)
	add_score(player_id, amount)
	_remove_brain.rpc(brain_path)

# The server calculates the score addition
func add_score(player_id: int, amount: int) -> void:
	if not multiplayer.is_server():
		return # Security check: only the server modifies state
	
	if not player_scores.has(player_id):
		player_scores[player_id] = 0
		
	player_scores[player_id] += amount
	
	# Broadcast the newly updated score to ALL clients (including local server)
	update_score_ui.rpc(player_id, player_scores[player_id])

# "authority" means only the server can invoke it.
# "call_local" ensures the server also runs it for its own UI.
@rpc("authority", "call_local", "reliable")
func update_score_ui(player_id: int, new_score: int) -> void:
	player_scores[player_id] = new_score
	score_updated.emit(player_id, new_score)

@rpc("authority", "call_local", "reliable")
func _remove_brain(brain_path: NodePath) -> void:
	var brain := get_node_or_null(brain_path)
	if brain:
		brain.queue_free()

func _sync_scores_to_peer(id: int) -> void:
	if id == multiplayer.get_unique_id():
		return
	_sync_score_state.rpc_id(id, player_scores.duplicate(), collected_brain_paths.duplicate())

# A peer who joins after pickups must receive the score table and lose those brains.
@rpc("authority", "reliable")
func _sync_score_state(scores: Dictionary, brain_paths: Array) -> void:
	player_scores = scores
	for player_id in player_scores.keys():
		score_updated.emit(int(player_id), int(player_scores[player_id]))
	for brain_path in brain_paths:
		var brain := get_node_or_null(brain_path)
		if brain:
			brain.queue_free()
#endregion
