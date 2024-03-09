extends Node

## Signal to change into the game over screen.
signal game_over

## Signal which is emitted by the game over screen when the player pressed the try again button
signal try_again

## Signal which is emitted by the pause menu when the player wants to resume the game
signal resume

## Signal which is emitted by the pause menu and game over screen when the player wants to exit the game
signal game_exited

## Signal for passing changed player health to the health UI elements
signal health_changed(health: float)

