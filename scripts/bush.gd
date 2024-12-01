extends Node2D

func _ready():
	if randi_range(0, 1) == 1:
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("idle2")

func die():
	$AnimatedSprite2D.play("die")
	$Timer.start(0.5)

func _on_timer_timeout():
	queue_free()
