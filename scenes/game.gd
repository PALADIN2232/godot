extends Node2D

@onready var health_bar = $CanvasLayer/HealthBar
@onready var player = $Player

func _ready():
	player.connect("health_changed", Callable(self, "_on_player_health_changed"))
	health_bar.value = player.health


func _on_player_health_changed(new_health):
	health_bar.value = new_health 
