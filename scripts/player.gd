extends CharacterBody2D

@export var run_speed: float = 360.0
@export var jump_velocity: float = -975.0
@export var gravity: float = 3750.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var camera: Camera2D = $Camera2D

func _physics_process(delta: float) -> void:
    # --- Constant run right ---
    velocity.x = run_speed
    
    # --- Gravity---
    if not is_on_floor():
        velocity.y += gravity * delta
    
    # --- Jump ---
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity
        jump_sound.play()
    
    move_and_slide()   
       
    # --- Animation  ---
    if not is_on_floor():
        animated_sprite.play("jump")
    else:
        animated_sprite.play("walk")