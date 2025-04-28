extends Control
class_name LoadingScreen

#NOTE: this is the script i got from official godot website on one of the comments, i tweak a little to fit the game.

#this is for loading tip
var loading_tips = [
	"Test tip",
	"Test tip 2",
	"Test tip 3"
]

@onready var progress_bar = $Panel/ProgressBar

## The path to the scene that's actually being loaded
var path: String

# loading percentage
@onready var percentage_text = $Panel/Percentage

#loading tip
@onready var loading_tip_label = $"Panel/Loading tip"

## Actual progress value; we move towards towards this
var progress_value := 0.0

## Load the scene at the given path.
## When this is finished loading, the "scene_loaded" signal will be emitted.
func load(path_to_load: String):
	path = path_to_load
	ResourceLoader.load_threaded_request(path)
	
	#play the tips on screen
	var rng = RandomNumberGenerator.new()
	var random_tip = rng.randi_range(0, loading_tips.size() - 1)
	loading_tip_label.text = loading_tips[random_tip]

func _process(delta: float):
	if not path:
		return

	var progress = []
	var status = ResourceLoader.load_threaded_get_status(path, progress)

	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
		progress_value = progress[0] * 100
		progress_bar.value = move_toward(progress_bar.value, progress_value, delta * 20)

	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		# zip the progress bar to 100% so we don't get weird visuals
		progress_bar.value = move_toward(progress_bar.value, 100.0, delta * 150)

		# "done" loading :)
		if progress_bar.value >= 99:
			get_tree().change_scene_to_file(path)

	percentage_text.text = str(int(progress_bar.value)) + "%"
