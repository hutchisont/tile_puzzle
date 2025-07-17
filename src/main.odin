package tile_puzzle

import "core:c"
import "core:fmt"
import "core:log"
import "core:mem"
import "core:os"

import mu "vendor:microui"
import rl "vendor:raylib"

// Prevent -vet from bitching about these being unused when we're not using the
// tracking allocator.
_ :: fmt
_ :: mem

State := struct {
	mu_ctx:         mu.Context,
	bg:             mu.Color,
	atlas_texture:  rl.RenderTexture2D,
	screen_width:   c.int,
	screen_height:  c.int,
	screen_texture: rl.RenderTexture2D,
} {
	screen_width  = 960,
	screen_height = 960,
	bg            = {100, 149, 237, 255},
}

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	context.logger = log.create_console_logger(lowest = log.Level.Info)

	rl.SetTraceLogLevel(.ERROR)
	rl.SetConfigFlags({.MSAA_4X_HINT, .VSYNC_HINT})

	rl.InitWindow(State.screen_width, State.screen_height, "Tile Puzzle")
	defer rl.CloseWindow()

	rl.SetTargetFPS(144)

	ctx := &State.mu_ctx
	mu.init(ctx)

	State.screen_texture = rl.LoadRenderTexture(State.screen_width, State.screen_height)
	defer rl.UnloadRenderTexture(State.screen_texture)

	for !rl.WindowShouldClose() {
		free_all(context.temp_allocator)
	}
}
