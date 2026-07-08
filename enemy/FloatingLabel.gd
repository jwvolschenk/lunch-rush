extends Label
## FloatingLabel — a popup label that floats upward and fades out.
## Used for enemy death feedback (gold/score popups).
##
## Usage:
##   var label = FloatingLabel.new()
##   label.setup("gold", "+10", Color(1.0, 0.85, 0.1, 1.0), 1.5)
##   parent.add_child(label)

var _duration: float = 1.5
var _elapsed: float = 0.0
var _float_speed: float = 40.0
var _text_color: Color = Color.WHITE

## Set up this floating label.
## text: the display text (e.g. "+10")
## text_color: the label color
## duration: how long until the label disappears
func setup(text: String, text_color: Color, duration: float = 1.5) -> void:
	_duration = duration
	_elapsed = 0.0
	_text_color = text_color
	self.text = text
	self.autowrap_mode = TextServer.AUTOWRAP_OFF
	self.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	self.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	self.font_size = 20
	self.add_theme_color_override("font_color", text_color)
	self.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
	self.add_theme_constant_override("font_outline_size", 2)
	self.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE

## Called once per frame while the label is alive
func _process(delta: float) -> void:
	_elapsed += delta
	var t = _elapsed / _duration

	# Float upward
	position.y -= _float_speed * delta

	# Fade out in the last third of the duration
	if t > 0.66:
		var fade_t = (t - 0.66) / 0.34
		self.add_theme_color_override("font_color",
			Color(_text_color.r, _text_color.g, _text_color.b, 1.0 - fade_t))

	if _elapsed >= _duration:
		queue_free()
