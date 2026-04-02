extends Node2D

@export var base_game_speed: float = 360.0
@export var min_gap_between_obstacles: float = 220.0   # pixels — tune this!

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var obstacle_timer: Timer = $ObstacleTimer
@onready var lblScore : Label = $ScoreLayer/lblScoreLbl/lblScore
@onready var bg_music : AudioStreamPlayer = $Music/BackgroundMusic
@onready var game_over_music : AudioStreamPlayer = $Music/GameOverMusic

var snail_scene: PackedScene = preload("res://scenes/Snail.tscn")
var fly_scene: PackedScene = preload("res://scenes/Fly.tscn")
 

var score: int = 0
var last_obstacle_x: float = -1000.0   # far left to start

var start_time: float = 0.0
var is_game_running: bool = true

func _input(event: InputEvent) -> void:
    if not is_game_running and $GameOverScreen.visible:
        if event.is_action_pressed("jump"):   # Space or Up arrow (same as your jump key)
            get_tree().reload_current_scene()   # Simple way to restart everything

func _ready() -> void:
    start_time = Time.get_ticks_msec() / 1000.0
    obstacle_timer.start(1.0)   # initial delay
    bg_music.play()

func _process(delta: float) -> void:
    if is_game_running:
        score = int(Time.get_ticks_msec() / 1000.0 - start_time)     
        var strScore : String = str(score)  
        lblScore.text = strScore        

func _on_obstacle_timer_timeout() -> void:
    if not is_game_running:
        return
    
    # Random burst size: 1 to 3 obstacles
    var burst_count: int = randi_range(1, 3)
    
    # Create a random sequence of obstacle types for this burst
    var sequence: Array = []
    for i in range(burst_count):
        var choices: Array[Variant] = ["snail", "snail", "snail", "fly"]   # biased toward snails
        sequence.append(choices.pick_random())
    
    # Spawn them one by one with random small delays between them
    for i in range(burst_count):
        spawn_single_obstacle(sequence[i])
        
        # Random delay between obstacles in the burst (0.25 to 0.7 seconds)
        if i < burst_count - 1:
            await get_tree().create_timer(randf_range(0.25, 0.7)).timeout
    
    # Random wait until the next burst starts (this creates the gaps)
    var next_wait: float = randf_range(0.8, 2.5)   # tune these numbers to your liking
    obstacle_timer.wait_time = next_wait
    obstacle_timer.start()

func spawn_single_obstacle(type: String) -> void:
    if is_game_running :
        var obstacle: Area2D
        var y_pos: float = 175.0 if type == "fly" else 140.0
        if type == "fly":
            obstacle = fly_scene.instantiate()            
        if type == "snail":
            obstacle = snail_scene.instantiate()
    
        # Spawn to the right of the camera
        obstacle.position.x = camera.get_screen_center_position().x + 700 + randf_range(-80, 180)
        obstacle.position.y = y_pos
        
        add_child(obstacle)
    
func game_over() -> void:
    is_game_running = false
    obstacle_timer.stop()   
    bg_music.stop()
    
    # Stop all obstacles from moving
    for obstacle in get_tree().get_nodes_in_group("obstacles"):
        obstacle.set_physics_process(false) 
    
    # Show the game over screen
    $GameOverScreen.show_game_over(score)
    game_over_music.play()
   
    
