extends Area2D

@export var speed: float = 360.0
@export var animation_name: String = "walk"   # Set this in Inspector: "walk" for Snail, "fly" for Fly

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    if animated_sprite == null:
        push_error("AnimatedSprite2D not found on " + name + "! Check node name and scene structure.")
        return
    
    animated_sprite.play(animation_name)   # This now safely starts the animation
    
    # Connect collision (we'll use body_entered so it detects CharacterBody2D)
    body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
    position.x -= speed * delta
    
    # Off-screen cleanup (left side) - safer than using camera here
    if position.x < -300:
        queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") or body.name == "Player":
        # Tell Main the game is over
        if get_parent().has_method("game_over"):
            get_parent().game_over()