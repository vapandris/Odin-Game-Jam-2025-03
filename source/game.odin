package game

import rl "vendor:raylib"
import "core:c"

run: bool

init :: proc() {
    run = true
    rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
    rl.InitWindow(1280, 720, "Odin + Raylib on the web")
	rl.SetExitKey(.KEY_NULL)

}

update :: proc() {
    rl.BeginDrawing()
    rl.ClearBackground({0, 120, 153, 255})

    rl.EndDrawing()

    // Anything allocated using temp allocator is invalid after this.
    free_all(context.temp_allocator)
}

draw :: proc() {

}

// In a web build, this is called when browser changes size. Remove the
// `rl.SetWindowSize` call if you don't want a resizable game.
parent_window_size_changed :: proc(w, h: int) {
    rl.SetWindowSize(c.int(w), c.int(h))
}

shutdown :: proc() {
    rl.CloseWindow()
}

should_run :: proc() -> bool {
    when ODIN_OS != .JS {
        // Never run this proc in browser. It contains a 16 ms sleep on web!
        if rl.WindowShouldClose() {
            run = false
        }
    }

    return run
}