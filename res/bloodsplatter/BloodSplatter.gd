extends GPUParticles3D

@onready var particles = $Particles

func _ready():
	particles.emitting = true

func _process(delta):
	if not particles.emitting:
		queue_free()
