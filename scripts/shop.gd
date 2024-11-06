extends Control

# Reference to the scroll container that will hold our scroll items
@onready var scroll_container = $CenterContainer/VBoxContainer/ScrollContainer/GridContainer

# Preload the card scene that we'll use as a base for shop items
const CARD_SCENE = preload("res://scenes/Card.tscn")

func _ready():
    setup_shop()
    $CenterContainer/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func setup_shop():
    # Add some sample locked scrolls
    for i in range(6):
        var card_instance = CARD_SCENE.instantiate()
        scroll_container.add_child(card_instance)
        
        # Make the card locked/uninteractive for now
        card_instance.modulate = Color(0.5, 0.5, 0.5, 1)
        
        # Add a lock overlay or indication that it's locked
        var lock_label = Label.new()
        lock_label.text = "🔒"
        lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        lock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        lock_label.set_anchors_preset(Control.PRESET_FULL_RECT)
        card_instance.add_child(lock_label)

func _on_back_pressed():
    get_node("/root/Main").show_main_menu() 