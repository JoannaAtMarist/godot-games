extends Node





func become_host():
	print("Starting host!")
	%MultiplayerHUD.hide()
	MultiplayerManager.become_host()




func join_as_player_2():
	print("Player 2 joining")
	%MultiplayerHUD.hide()
	MultiplayerManager.join_as_player_2()
