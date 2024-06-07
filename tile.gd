@tool
extends Area2D
class_name Tile

var COLORS = {
	"0": Color.hex(0x4c4c4cff),
	"2": Color.hex(0xeee4daff),
	"4": Color.hex(0xeee1c9ff),
	"8": Color.hex(0xf3b27aff),
	"16": Color.hex(0xf69664ff),
	"32": Color.hex(0xf77c5fff),
	"64": Color.hex(0xf75f3bff),
	"128": Color.hex(0xedd073ff),
	"256": Color.hex(0xedcc62ff),
	"512": Color.hex(0xedc950ff),
	"1024": Color.hex(0xedc53fff),
	"2048": Color.hex(0xedc22eff),
}

@export var value: int :
	set(new_value):
		value = new_value
		update()

func update() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.05)
	
	var color_name = str(2048 if value > 2048 else value)
	if COLORS.has(color_name):
		tween.parallel().tween_property($Background, "color", COLORS[color_name], 0.1)
	tween.chain().tween_property(self, "scale", Vector2.ONE, 0.05)
	
	if value > 4:
		$Number.add_theme_color_override("font_color", Color.WHITE)
	
	$Number.text = str(value)

func destroy() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), .25)
	tween.tween_callback(queue_free)
