extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is player:
		GameManager.add_münze()
		play_sound("coin")
		queue_free()

func play_sound(sound_type: String) -> void:
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = create_sound_stream(sound_type)
	get_tree().root.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)

func create_sound_stream(sound_type: String) -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.mix_rate = 22050
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false

	var duration: float = 0.12
	var frequency: float = 880.0
	var volume: float = 0.22
	var waveform: String = "sine"

	var sample_count = int(stream.mix_rate * duration)
	var data = PackedByteArray()

	for i in range(sample_count):
		var t = float(i) / stream.mix_rate
		var value = sin(2.0 * PI * frequency * t)
		var sample = int(value * volume * 32767.0)
		data.append(sample & 0xFF)
		data.append((sample >> 8) & 0xFF)

	stream.data = data
	return stream
