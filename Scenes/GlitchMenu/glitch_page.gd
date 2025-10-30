extends Control
class_name GlitchPage

signal terminal_finished
const LINES := [
	"[color=#00FF00][ OK ][/color] Reached target Basic System.",
	"[color=#00FF00][ OK ][/color] Started D-Bus System Message Bus.",
	"[color=#888888]         Starting Network Manager...[/color]",
	"[color=#00FF00][ OK ][/color] Started Network Manager.",
	"[color=#888888]         Starting WPA supplicant...[/color]",
	"[color=#FFAA00][WARN][/color] wlan0: authentication timed out",
	"[color=#888888]         Retrying connection (attempt 2/3)...[/color]",
	"[color=#00AAFF][ INFO ][/color] wlan0: associated with AP 94:FA:3C:5B:xx:xx",
	"[color=#00FF00][ OK ][/color] wlan0: link is up (54 Mbps)",
	"[color=#00FF00][ OK ][/color] Reached target Network is Online.",
	"[color=#888888]         Starting SSH daemon...[/color]",
	"[color=#00FF00][ OK ][/color] Started OpenSSH server daemon.",
	"[color=#888888]         Loading kernel modules...[/color]",
	"[color=#00AAFF][ INFO ][/color] Loading module: video_core (proprietary)",
	"[color=#FFAA00][WARN][/color] video_core: unsigned driver loaded (tainted kernel)",
	"[color=#888888]         Starting Display Manager...[/color]",
	"[color=#00FF00][ OK ][/color] Started Display Manager Service.",
	"[color=#00AAFF][ INFO ][/color] systemd[1]: Startup finished in 4.821s (kernel) + 8.342s (userspace)",
	"",
	"[color=#00FF00]debian-server login:[/color] [color=#FFFFFF]root[/color]",
	"[color=#00FF00]Password:[/color]",
	"[color=#00FF00]Last login:[/color] Mon Oct 27 23:14:08 2025 from 192.168.1.105",
	"[color=#FFFFFF]root@debian-server:~#[/color] [color=#FFAA00]dmesg | tail[/color]",
	"[color=#888888][ 12.483921] IPv6: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready[/color]",
	"[color=#888888][ 12.553104] wlan0: Limiting TX power to 23 (23 - 0) dBm[/color]",
	"[color=#FFFFFF]root@debian-server:~#[/color] [color=#FFAA00]systemctl status --failed[/color]",
	"[color=#00FF00]● 0 loaded units listed.[/color]",
	"[color=#FFFFFF]root@debian-server:~#[/color] [color=#FFAA00]uptime[/color]",
	"[color=#FFFFFF] 14:23:47 up 2 min, 1 user, load average: 0.52, 0.24, 0.09[/color]",
	"[color=#FFFFFF]root@debian-server:~#[/color]"
]
const TYPO_CHARS := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTVWXYZ1234567890~!@#$%^&*()_+`[]]\\;',./<>?:\"{}|"
var rng := RandomNumberGenerator.new()
@export var terminal : RichTextLabel
@export_category("Hackerman Tweaks")
## Seconds between characters
@export var base_delay = 0.01
## Max jitter to add to base_delay
@export var jitter = 0.04
## Delay between lines
@export var inter_line_delay = 0.5
## Requires BBCode
@export var cursor_char = "[color=#00FF00]█[/color]"
@export var cursor_blink_interval := 0.3
## Random chance to typo
@export_range(0.0, 1.0) var typo_chance := 0.03
var is_blinking = true

func _ready():
	rng.randomize()
	terminal.clear()
	terminal.bbcode_enabled = true
	terminal.text = ""
	terminal.clear()
	_cursor_blink()

func anim():
	is_blinking = false
	_type_lines()

func _type_lines():
	for l_idx in range(LINES.size()):
		var line = LINES[l_idx]
		#TODO Add randomized capitalizations / errors
		await _type_line(line)
		await get_tree().create_timer(inter_line_delay).timeout
	is_blinking = true
	_cursor_blink()
	await get_tree().create_timer(1., true).timeout
	terminal_finished.emit()

func _type_line(line:String):
	var buffer := ""
	var chars_to_type := line
	var made_typo := false
	
	var i = 0
	while i < chars_to_type.length():
		var _char = chars_to_type[i]
		
		# Skip BBCode tags - don't type them character by character
		if _char == '[':
			var close_bracket = chars_to_type.find("]", i)
			if close_bracket != -1:
				# Add entire tag at once
				buffer += chars_to_type.substr(i, close_bracket - i + 1)
				i = close_bracket + 1
				continue
		
		#TODO Maybe add mistakes or glitches here? Those random changing asci characters?
		buffer += _char
		_update_terminal_line(buffer)
		var delay = base_delay + rng.randf_range(-jitter, jitter)/2
		await get_tree().create_timer(delay).timeout
		i+=1
		#TODO Add thinking bewteen lines randomly?
		
		# Typo Logic 
		if not made_typo and _char.is_valid_identifier() and rng.randf() < typo_chance:
			var removed_self = TYPO_CHARS.replace(_char, "")
			var wrong_char = removed_self[randi_range(0, removed_self.length() - 1)]
			buffer += wrong_char
			_update_terminal_line(buffer)
			await get_tree().create_timer(base_delay + 0.15).timeout
			
			# DELETE mwahahha 
			#TODO Maybe make this timer variable? or have the person realize they made a mistake?
			buffer = buffer.substr(0, buffer.length() - 1)
			_update_terminal_line(buffer)
			await get_tree().create_timer(0.05).timeout
			#made_typo = true
		
	# Remove cursor, new line.
	var bb = terminal.text 
	if bb.ends_with(cursor_char):
		bb = bb.substr(0, bb.length() - cursor_char.length()	)
	if line == LINES[LINES.size()-1]: return
	terminal.text = bb + "\n"
func _update_terminal_line(new_text:String):
	var all_bb := terminal.text
	var last_nl := all_bb.rfind("\n")
	var prefix := ""
	if last_nl >= 0:
		prefix = all_bb.substr(0, last_nl + 1)
	var display_line : String = (new_text) + cursor_char
	terminal.text = prefix + display_line
	terminal.scroll_to_line(terminal.get_line_count() - 1)
	
	await get_tree().process_frame
	terminal.scroll_to_line(terminal.get_line_count())

func stop_cursor_blink():
	is_blinking = false
	var bb = terminal.text 
	if bb.ends_with(cursor_char):
		bb = bb.substr(0, bb.length() - cursor_char.length()	)
	terminal.text = bb

func _cursor_blink():
	var bb = terminal.text 
	if bb.ends_with(cursor_char):
		bb = bb.substr(0, bb.length() - cursor_char.length()	)
		if bb.ends_with("\n"):
			bb = bb.substr(0, bb.length()-1)
	else:
		if bb.ends_with("\n"):
			bb = bb.substr(0, bb.length()-1)
		bb = bb + cursor_char
	#bb = bb + cursor_char
	terminal.text = bb
	await get_tree().create_timer(cursor_blink_interval, true).timeout
	if is_blinking:
		_cursor_blink()
