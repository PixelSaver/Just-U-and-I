extends Control

const LINES := [
	"[color=#00FF00][BOOT][/color] JUIOS v7.3.1 - JULIUS UI/OS",
	"[color=#888888][...initializing subsystems...][/color]",
	"[color=#00FF00][OK][/color] DISPLAY        : framebuffer@0x00ff1a",
	"[color=#00FF00][OK][/color] INPUT          : polled HID devices (4)",
	"[color=#FFAA00][WARN][/color] QA_SUBSYS     : missing unit-tests — applying band-aid",
	"[color=#00AAFF][INFO][/color] AUTH         -> kernel handshake... OK",
	"[color=#00AAFF][SCAN][/color] NETWORK      : scanning 12 nets",
	"[color=#FF00FF][SPOOF][/color] MAC_ADDR    : 94:FA:3C:5B:xx:xx",
	"[color=#FF00FF][CRACK][/color] PASSPHRASE  : attempting dictionary (leetspeak mode)",
	"[color=#FFAA00][GLITCH][/color] JUIOS.CORE : injecting caffeine.dll -> status: ☕️",
	"[color=#888888][TRACE][/color] /usr/juios/secret -> read 0xDEADBEEF bytes... readable?",
	"[color=#00FF00][ACCESS GRANTED][/color] user: [color=#00FF00][b]root.juice[/b][/color]",
	"[color=#FF00FF][LAUNCH][/color] /usr/juios/party_mode --flags=🎉 --tempo=1337",
	"[color=#FF0000][!][/color] Unexpected: karaoke module loaded. Singing in 3...2...1...",
	"[color=#00AAFF][OUTPUT][/color] SYSTEM --> [color=#FFFF00]\"All your widgets are belong to us.\"[/color]"
]
var rng := RandomNumberGenerator.new()
@export var terminal : RichTextLabel
@export_category("Hackerman Tweaks")
## Seconds between characters
@export var base_delay = 0.025
## Max jitter to add to base_delay
@export var jitter = 0.04
## Delay between lines
@export var inter_line_delay = 0.5
## Requires BBCode
@export var cursor_char = "[color=#00FF00]█[/color]"

func _ready():
	rng.randomize()
	terminal.clear()
	terminal.bbcode_enabled = true
	_type_lines()

func _type_lines():
	for l_idx in range(LINES.size()):
		var line = LINES[l_idx]
		#TODO Add randomized capitalizations / errors
		await _type_line(line)
		await get_tree().create_timer(inter_line_delay).timeout

func _type_line(line:String):
	var buffer := ""
	for i in range(line.length()):
		var char := line[i]
		#TODO Maybe add mistakes or glitches here? Those random changing asci characters?
		buffer += char
		_update_terminal_line(buffer)
		var delay = base_delay + rng.randf_range(-jitter, jitter)/2
		await get_tree().create_timer(delay).timeout
		#TODO Add thinking bewteen lines randomly?
		
	# Remove cursor, new line.
	var bb = terminal.text 
	if bb.ends_with(cursor_char):
		bb = bb.substr(0, bb.length() - cursor_char.length()-1)
	terminal.text += "\n"
func _update_terminal_line(new_text:String):
	var all_bb := terminal.text
	var last_nl := all_bb.rfind("\n")
	var prefix := ""
	if last_nl >= 0:
		prefix = all_bb.substr(0, last_nl + 1)
	var display_line : String = (new_text) + cursor_char
	terminal.text = prefix + display_line
	terminal.scroll_to_line(terminal.get_line_count() - 1)
