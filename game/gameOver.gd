extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var team

func _ready():
	$RichTextLabel.text = "Team " + Global.winning_team + " won"
