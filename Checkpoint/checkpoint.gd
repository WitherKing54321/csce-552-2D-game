extends Area2D

@export var player_group: String = "player"
@export var activate_duration: float = 1.3  # seconds for Activate animation

var anim: AnimatedSprite2D
var prompt_label: Label
var player: Node = null

var can_interact = false
var activated = false
var activate_timer = 0.0
var in_activation = false

func _ready():
	anim = $AnimatedSprite2D
	anim.play("Idle")  # start idle animation
	
	# Reference the prompt label as a child
	prompt_label = $InteractionPrompt
	prompt_label.visible = false
	
	# Connect Area2D signals
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Find player node
	player = get_tree().get_first_node_in_group(player_group)


func _process(delta):
	# Player in range and not yet activated
	if can_interact and not activated:
		if Input.is_action_just_pressed("ui_accept"):  # default "E" key
			activated = true
			start_activation()
	
	# Handle activation timer
	if in_activation:
		activate_timer -= delta
		if activate_timer <= 0:
			in_activation = false
			anim.play("ActivateIdle")  # switch to idle after activation


func _on_body_entered(body):
	if body.is_in_group(player_group) and not activated:
		can_interact = true
		show_prompt()


func _on_body_exited(body):
	if body.is_in_group(player_group):
		can_interact = false
		hide_prompt()


func show_prompt():
	if prompt_label:
		prompt_label.text = "Press [ENTER] to activate"
		prompt_label.visible = true
		
func hide_prompt():
	if prompt_label:
		prompt_label.visible = false

func start_activation():
	hide_prompt()
	anim.play("Activate")
	activate_timer = activate_duration
	in_activation = true
