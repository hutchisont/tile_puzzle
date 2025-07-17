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

CORNFLOWER_BLUE: mu.Color : {100, 149, 237, 255}

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
	bg            = CORNFLOWER_BLUE,
}

Mouse_Buttons_Map := [mu.Mouse]rl.MouseButton {
	.LEFT   = .LEFT,
	.RIGHT  = .RIGHT,
	.MIDDLE = .MIDDLE,
}

Key_Map := [mu.Key][2]rl.KeyboardKey {
	.SHIFT     = {.LEFT_SHIFT, .RIGHT_SHIFT},
	.CTRL      = {.LEFT_CONTROL, .RIGHT_CONTROL},
	.ALT       = {.LEFT_ALT, .RIGHT_ALT},
	.BACKSPACE = {.BACKSPACE, .KEY_NULL},
	.DELETE    = {.DELETE, .KEY_NULL},
	.RETURN    = {.ENTER, .KP_ENTER},
	.LEFT      = {.LEFT, .KEY_NULL},
	.RIGHT     = {.RIGHT, .KEY_NULL},
	.HOME      = {.HOME, .KEY_NULL},
	.END       = {.END, .KEY_NULL},
	.A         = {.A, .KEY_NULL},
	.X         = {.X, .KEY_NULL},
	.C         = {.C, .KEY_NULL},
	.V         = {.V, .KEY_NULL},
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
	defer log.destroy_console_logger(context.logger)

	rl.SetTraceLogLevel(.ERROR)
	rl.SetConfigFlags({.MSAA_4X_HINT, .VSYNC_HINT})

	rl.InitWindow(State.screen_width, State.screen_height, "Tile Puzzle")
	defer rl.CloseWindow()

	rl.SetTargetFPS(144)

	ctx := &State.mu_ctx
	mu.init(ctx)

	ctx.text_width = mu.default_atlas_text_width
	ctx.text_height = mu.default_atlas_text_height

	State.atlas_texture = rl.LoadRenderTexture(
		c.int(mu.DEFAULT_ATLAS_WIDTH),
		c.int(mu.DEFAULT_ATLAS_HEIGHT),
	)
	defer rl.UnloadRenderTexture(State.atlas_texture)

	image := rl.GenImageColor(
		c.int(mu.DEFAULT_ATLAS_WIDTH),
		c.int(mu.DEFAULT_ATLAS_HEIGHT),
		rl.Color{0, 0, 0, 0},
	)
	defer rl.UnloadImage(image)

	for alpha, i in mu.default_atlas_alpha {
		x := i % mu.DEFAULT_ATLAS_WIDTH
		y := i / mu.DEFAULT_ATLAS_WIDTH
		color := rl.Color{255, 255, 255, alpha}
		rl.ImageDrawPixel(&image, c.int(x), c.int(y), color)
	}

	rl.BeginTextureMode(State.atlas_texture)
	rl.UpdateTexture(State.atlas_texture.texture, rl.LoadImageColors(image))
	rl.EndTextureMode()

	State.screen_texture = rl.LoadRenderTexture(State.screen_width, State.screen_height)
	defer rl.UnloadRenderTexture(State.screen_texture)

	for !rl.WindowShouldClose() {
		free_all(context.temp_allocator)

		mouse_pos := rl.GetMousePosition()
		mouse_x, mouse_y := i32(mouse_pos.x), i32(mouse_pos.y)
		mu.input_mouse_move(ctx, mouse_x, mouse_y)

		mouse_wheel_pos := rl.GetMouseWheelMoveV()
		mu.input_scroll(ctx, i32(mouse_wheel_pos.x) * 30, i32(mouse_wheel_pos.y) * -30)

		mu.begin(ctx)
		mu.end(ctx)

		render(ctx)
	}
}

render :: proc(ctx: ^mu.Context) {
	render_texture :: proc(
		renderer: rl.RenderTexture2D,
		dst: ^rl.Rectangle,
		src: mu.Rect,
		color: rl.Color,
	) {
		dst.width = f32(src.w)
		dst.height = f32(src.h)

		rl.DrawTextureRec(
			texture = State.atlas_texture.texture,
			source = {f32(src.x), f32(src.y), f32(src.w), f32(src.h)},
			position = {dst.x, dst.y},
			tint = color,
		)
	}

	to_rl_color :: proc(c: mu.Color) -> rl.Color {
		return rl.Color{c.r, c.g, c.b, c.a}
	}

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)
	rl.DrawTextureRec(
		texture = State.screen_texture.texture,
		source = {0, 0, f32(State.screen_width), -f32(State.screen_height)},
		position = {0, 0},
		tint = rl.WHITE,
	)

	rl.EndDrawing()
}
