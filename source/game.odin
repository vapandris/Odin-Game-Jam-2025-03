package game

import rl "vendor:raylib"
import "core:c"

run: bool
Game :: struct {
    epiglottis: [5]HitCircle,
    windpipe: [2]HitBox,
    foodpipe:    HitBox,
    windpipeTop: [2]HitCircle,
    foodpipeTop:    HitCircle,

    camera: rl.Camera2D,
}
WINDOW_WIDTH  :: 1280.0
WINDOW_HEIGHT :: 720.0

WORLD_WIDTH  :: 1280.0
WORLD_HEIGHT :: 720.0

game :^Game

init :: proc() {
    run = true
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "epiglottis")
    rl.SetExitKey(.KEY_NULL)

    /* -- -- -- -- -- -- -- -- -- */
    game = new(Game)
    game^ = Game{}

    PIPE_SIZE :: Vec2{64, WORLD_HEIGHT*0.5}
    game.windpipe = {
        HitBox {
            pos = {
                WORLD_WIDTH*1/3 - PIPE_SIZE.x/2,
                WORLD_HEIGHT * 0.5,
            },
            size = PIPE_SIZE,
        },
        HitBox {
            pos = {
                WORLD_WIDTH*1/2 - PIPE_SIZE.x/2,
                WORLD_HEIGHT * 0.5,
            },
            size = PIPE_SIZE,
        },
    }
    game.foodpipe = HitBox {
        pos = {
            WORLD_WIDTH*2/3 - PIPE_SIZE.x/2,
            WORLD_HEIGHT * 0.5,
        },
        size = PIPE_SIZE,
    }
    game.windpipeTop = {
        HitCircle{
            pos = game.windpipe[0].pos + {game.windpipe[0].size.x/2, 0},
            r = game.windpipe[0].size.x/2,
        },
        HitCircle{
            pos = game.windpipe[1].pos + {game.windpipe[1].size.x/2, 0},
            r = game.windpipe[1].size.x/2,
        },
    }
    game.foodpipeTop = HitCircle{
        pos = game.foodpipe.pos + {game.foodpipe.size.x/2, 0},
        r = game.foodpipe.size.x/2,
    }

    game.camera.offset = Vec2{
        WINDOW_WIDTH/2,
        WINDOW_HEIGHT/2,
    }
    game.camera.target = Vec2{
        WORLD_WIDTH/2,
        WORLD_HEIGHT/2,
    }
    game.camera.zoom = 1
}

update :: proc() {
    assert(rl.GetScreenWidth() == WINDOW_WIDTH)
    assert(rl.GetScreenHeight() == WINDOW_HEIGHT)

    // Anything allocated using temp allocator is invalid after this.
    free_all(context.temp_allocator)
}

draw :: proc() {
    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)

    {
        rl.BeginMode2D(game.camera)
        defer rl.EndMode2D()

        rl.DrawRectangleV(game.windpipe[0].pos, game.windpipe[0].size, rl.BLUE)
        rl.DrawRectangleV(game.windpipe[1].pos, game.windpipe[1].size, rl.BLUE)
        rl.DrawRectangleV(game.foodpipe.pos, game.foodpipe.size, rl.RED)
        rl.DrawCircleV(game.windpipeTop[0].pos, game.windpipeTop[0].r, rl.BLUE)
        rl.DrawCircleV(game.windpipeTop[1].pos, game.windpipeTop[1].r, rl.BLUE)
        rl.DrawCircleV(game.foodpipeTop.pos, game.foodpipeTop.r, rl.RED)


    }

    rl.EndDrawing()
}

// In a web build, this is called when browser changes size. Remove the
// `rl.SetWindowSize` call if you don't want a resizable game.
parent_window_size_changed :: proc(w, h: int) {
    rl.SetWindowSize(c.int(w), c.int(h))
}

shutdown :: proc() {
    rl.CloseWindow()
    free(game)
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