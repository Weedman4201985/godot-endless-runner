extends CanvasLayer

@onready var score_label: Label = $lblScoreTitle/lblScore  # rename to match your node

func _ready() -> void:
    visible = false

# Optional: fade in or animate when shown
func show_game_over(final_score: int) -> void:
    score_label.text = str(final_score)
    visible = true
