extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var team

func end_game(team):
	$Camera2D.current = true
	$RichTextLabel.text = "Team " + team + " won"
