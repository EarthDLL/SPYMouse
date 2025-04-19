extends Area2D

@onready var sprite: Sprite2D = $Sprite
var trapped_texture : Texture2D = load("uid://b5dal50dlfc11")
var is_used := false

func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if is_instance_valid(player):
		var result := false
		for index in player.collected_items.size():
			if player.collected_items[index] is MouseToy:
				result = true
				var toy : MouseToy = player.collected_items[index]
				player.collected_items[index] = null
				player.deal_all_items()
				toy.queue_free()
				break
		if result:
			finish()
		else:
			player.state = Player.State.DIE
			player.hide()
			sprite.texture = trapped_texture
			sprite.hframes = 3
			var tween := create_tween()
			tween.tween_property(sprite,"frame",2,0.5)
			Game.current_level.fail(2.0,player.global_position)
		set_deferred("monitoring",false)

func finish() -> void:
	var tween := create_tween()
	tween.tween_property($Sprite,"frame",7,1.0)
	tween.tween_interval(1.5)
	tween.tween_property(self,"modulate:a",0.0,2)
	await tween.finished.connect(queue_free)
