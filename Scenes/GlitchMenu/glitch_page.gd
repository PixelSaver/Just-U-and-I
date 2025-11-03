extends Control
class_name GlitchPage

signal terminal_finished

const LINES := [
	"[color=#00FF00][ OK ][/color] Initializing system scan...",
	"[color=#888888]         Detecting network interfaces...[/color]",
	"[color=#00AAFF][ INFO ][/color] Found wireless adapter: Intel(R) Wi-Fi 6",
	"[color=#00FF00][ OK ][/color] Network connection established.",
	"",
	"[color=#FF0000][ ALERT ][/color] Unauthorized access detected from IP: 185.220.101.47",
	"[color=#FFAA00][WARN][/color] Firewall bypass attempt in progress...",
	"[color=#888888]         Analyzing security protocols...[/color]",
	"[color=#FF0000][ CRITICAL ][/color] Password hash cracking: 23% complete",
	"DELETE_PREV",
	"[color=#FF0000][ CRITICAL ][/color] Password hash cracking: 67% complete",
	"DELETE_PREV",
	"[color=#FF0000][ CRITICAL ][/color] Password hash cracking: 100% complete",
	"[color=#00FF00][ OK ][/color] Administrator credentials obtained.",
	"",
	"[color=#888888]         Establishing remote connection...[/color]",
	"[color=#00AAFF][ INFO ][/color] SSH tunnel created on port 4444",
	"[color=#00FF00][ OK ][/color] Remote access granted.",
	"",
	"download --file spy_malware.exe",
	"HACKER",
	"[color=#888888]         Transfer progress: [████░░░░░░] 40% (2.3 MB/5.8 MB)[/color]",
	"DELETE_PREV",
	"[color=#888888]         Transfer progress: [███████░░░] 70% (4.1 MB/5.8 MB)[/color]",
	"DELETE_PREV",
	"[color=#00FF00][ OK ][/color] Download complete: spy_malware.exe",
	"",
	"[color=#888888]         Installing malware to system32...[/color]",
	"[color=#00AAFF][ INFO ][/color] Disabling antivirus software...",
	"[color=#00FF00][ OK ][/color] Windows Defender has been disabled.",
	"[color=#888888]         Creating backdoor access...[/color]",
	"[color=#00FF00][ OK ][/color] Backdoor installed successfully.",
	"",
	"HACKER:extracting passwords and credit cards",
	"[color=#888888]         Scanning documents folder...[/color]",
	"[color=#888888]         Scanning downloads folder...[/color]",
	"[color=#888888]         Extracting browser passwords...[/color]",
	"[color=#00AAFF][ INFO ][/color] Found 47 saved passwords",
	"[color=#00AAFF][ INFO ][/color] Found 12 credit card numbers",
	"[color=#888888]         Uploading data to remote server...[/color]",
	"[color=#00FF00][ OK ][/color] Data exfiltration complete.",
	"",
	"HACKER:rm -rf /var/log/*",
	"[color=#888888]         Removing log files...[/color]",
	"[color=#00FF00][ OK ][/color] All evidence erased.",
	"",
	"[color=#00FF00]HACK COMPLETE - YOUR COMPUTER HAS BEEN COMPROMISED[/color]",
	"[color=#FFAA00]Panic, but do nothing. Because you can't do anything.[/color]"
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
	var l_idx = 0
	while l_idx < LINES.size():
		var line = LINES[l_idx]
		var has_typo = false
		match line:
			"DELETE_PREV":
				_delete_terminal_line(LINES[l_idx-1])
				l_idx += 1
				continue
			"HACKER":
				has_typo = true
		await _type_line(line, has_typo)
		await get_tree().create_timer(inter_line_delay).timeout
		l_idx += 1
	is_blinking = true
	_cursor_blink()
	await get_tree().create_timer(1., true).timeout
	terminal_finished.emit()

func _type_line(line:String, has_typo:bool):
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
		if not made_typo and _char.is_valid_identifier() and has_typo and rng.randf() < typo_chance:
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
func _delete_terminal_line(last_line):
	var all_bb := terminal.text
	var idx := all_bb.rfind(last_line)
	all_bb.replace(all_bb[idx], "")
	
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
