@tool
extends Area2D

@export var is_large := false :
	set(v):
		is_large = v
		if is_node_ready():
			update()

var size_small : Texture2D = load("uid://nqswqnemkxwk")
var size_large : Texture2D = load("uid://dw60sddoyunir")
@onready var sprite: Sprite2D = $Sprite

func update() -> void:
	if is_large:
		sprite.texture = size_large
	else:
		sprite.texture = size_small

func _ready() -> void:
	update()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var effect := PepperEffect.new()
		effect.is_large = is_large
		effect.total_time = 15
		effect.left_time = 15
		body.pepper_effect = effect
		queue_free()
