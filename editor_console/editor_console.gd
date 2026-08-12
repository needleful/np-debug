@tool
class_name NPConsole
extends Control

@export var text: CodeEdit
@export var run_button: Button
@export var run_selected_button: Button
@export var message_box: Container
@export var clear_button: Button
@export var scroll: ScrollContainer
@export var status: Label

var header := """
@tool
class_name NPLiveScriptClass
extends NPConsoleScript
var console:Control
func _console_run():
"""

var engine: NPConsoleScript = NPConsoleScript.new()

enum Message {
	Normal,
	Warning,
	Error
}

var tween : Tween

func _ready():
	run_button.pressed.connect(_run_all)
	run_selected_button.pressed.connect(_run_selected)
	clear_button.pressed.connect(_clear)

func _run_all():
	_clear_lines()
	_run()

func _run_selected():
	_clear_lines()
	var t := text.get_selected_text()
	var line := text.get_caret_line()
	if not t:
		t = text.get_line(line)
	var lines := t.count('\n')
	if lines == 0 and not t.contains(' = '):
		t = 'return ' + t
	text.set_line_as_executing(line, true)
	for i in range(lines+1):
		text.set_line_as_executing(line+i, true)
	print('Running: ', t)
	_run(t)

func _run(subset := ''):
	if not subset:
		subset = text.text
	var code := ''
	for t in subset.split('\n'):
		code += '\t' + t + '\n'
	var s := GDScript.new()
	s.source_code = header + code
	print('---')
	print(s.source_code)
	print('---')
	
	var e := s.reload()
	if e != OK:
		err('Could not parse code! Error code: %d' % e)
		return
	engine.set_script(s)
	engine.console = self
	var result = engine._console_run()
	write(str(result))

func _clear_lines():
	for l in text.get_executing_lines():
		text.set_line_as_executing(l, false)

func err(string: String):
	write(string, Message.Error)

func warn(string: String):
	write(string, Message.Warning)

func write(string: String, mode = Message.Normal):
	var l := Label.new()
	l.autowrap_mode = TextServer.AUTOWRAP_WORD
	l.text = string
	match mode:
		Message.Normal:
			print(string)
		Message.Warning:
			push_warning(string)
			l.add_theme_color_override('font_color', Color.ORANGE)
		Message.Error:
			push_error(string)
			l.add_theme_color_override('font_color', Color.LIGHT_CORAL)
	l.add_theme_constant_override('outline_size', 2)
	message_box.add_child(l)
	_scroll_tween(l.get_line_count()*l.get_line_height())

func _scroll_tween(height: int):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(
		scroll, 'scroll_vertical',
		scroll.get_v_scroll_bar().max_value + height,
		0.2
	).set_ease(Tween.EASE_OUT)

func _clear():
	for m in message_box.get_children():
		m.queue_free()
