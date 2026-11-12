class_name Sfx
extends RefCounted
## Sonidos generados en código (tonos y "swish"), sin archivos de audio externos.

const RATE := 22050
const SOUNDS := {
	"tap": [{"f0": 900.0, "f1": 600.0, "d": 0.05, "v": 0.35}],
	"flip": [{"f0": 300.0, "f1": 900.0, "d": 0.12, "v": 0.25, "n": 0.4}],
	"open": [{"f0": 400.0, "f1": 800.0, "d": 0.10, "v": 0.35}, {"f0": 800.0, "f1": 1200.0, "d": 0.12, "v": 0.35}],
	"close": [{"f0": 700.0, "f1": 350.0, "d": 0.10, "v": 0.35}, {"f0": 350.0, "f1": 250.0, "d": 0.08, "v": 0.30}],
	"swish": [{"f0": 180.0, "f1": 180.0, "d": 0.22, "v": 0.20, "n": 0.9}],
	"draw": [{"f0": 1400.0, "f1": 1400.0, "d": 0.03, "v": 0.20, "n": 0.5}],
	"vote": [{"f0": 700.0, "f1": 700.0, "d": 0.05, "v": 0.35}, {"f0": 1000.0, "f1": 1000.0, "d": 0.08, "v": 0.35}],
	"enact": [{"f0": 523.0, "f1": 523.0, "d": 0.10, "v": 0.35}, {"f0": 659.0, "f1": 659.0, "d": 0.10, "v": 0.35}, {"f0": 784.0, "f1": 784.0, "d": 0.22, "v": 0.35}],
	"fail": [{"f0": 300.0, "f1": 150.0, "d": 0.35, "v": 0.40}],
}
static var cache: Dictionary = {}
static var muted := false


static func play(sound: String) -> void:
	if muted:
		return
	if not SOUNDS.has(sound):
		return
	if not cache.has(sound):
		cache[sound] = _make(sound)
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = cache[sound]
	p.volume_db = -3.0
	tree.root.add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


static func _make(sound: String) -> AudioStreamWAV:
	var segs: Array = SOUNDS[sound]
	var total := 0
	for s in segs:
		total += int(float(s["d"]) * RATE)
	var buf := PackedByteArray()
	buf.resize(total * 2)
	var idx := 0
	var phase := 0.0
	for s in segs:
		var n := int(float(s["d"]) * RATE)
		var f0: float = s["f0"]
		var f1: float = s["f1"]
		var vol: float = s["v"]
		var noise: float = s.get("n", 0.0)
		for i in n:
			var t := float(i) / float(n)
			var f := lerpf(f0, f1, t)
			phase += TAU * f / float(RATE)
			var sample := sin(phase) * (1.0 - noise) + randf_range(-1.0, 1.0) * noise
			var env := (1.0 - t) * minf(1.0, float(i) / 60.0)
			buf.encode_s16(idx * 2, int(clampf(sample * env * vol, -1.0, 1.0) * 32000.0))
			idx += 1
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = buf
	return w
