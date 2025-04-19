extends Resource
class_name EffectTexture

@export var texture : Texture2D = null
@export var offest := Vector2.ZERO
@export var anima_texture : SpriteFrames = null
@export var scale := Vector2(1,1)

func stick_to_sprite(node : Sprite2D) -> void:
	node.texture = texture
	node.position = offest
	node.scale = scale
	
func stick_to_animated_sprite(node : AnimatedSprite2D) -> void:
	node.sprite_frames = anima_texture
	node.position = offest
	node.scale = scale
