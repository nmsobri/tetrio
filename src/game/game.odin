// const std = @import("std");
// const err = std.log.err;
// const c = @import("../sdl.zig");

// const Timer = @import("Timer.zig");
// const constant = @import("../constant.zig");
// const StateMachine = @import("StateMachine.zig");
// const StartState = @import("../state/StartState.zig");
// const Self = @This();

// fps_timer: Timer = undefined,
// window: ?*c.SDL_Window = null,
// renderer: ?*c.SDL_Renderer = null,
// allocator: std.mem.Allocator = undefined,
// state_machine: *StateMachine = undefined,

// pub fn init(allocator: std.mem.Allocator) !Self {
//     if (c.SDL_Init(c.SDL_INIT_VIDEO | c.SDL_INIT_AUDIO) < 0) {
//         err("Couldn't initialize SDL: {s}", .{c.SDL_GetError()});
//         return error.ERROR_INIT_SDL;
//     }

//     // Initialize SDL_mixer
//     if (c.Mix_OpenAudio(44100, c.MIX_DEFAULT_FORMAT, 2, 2048) < 0) {
//         std.log.err("SDL_mixer could not initialize! SDL_mixer Error: {s}\n", .{c.Mix_GetError()});
//         return error.ERROR_INIT_MIXER;
//     }

//     var self = Self{
//         .fps_timer = Timer.init(),
//         .allocator = allocator,
//     };

//     self.window = c.SDL_CreateWindow(
//         constant.GAME_NAME,
//         c.SDL_WINDOWPOS_CENTERED,
//         c.SDL_WINDOWPOS_CENTERED,
//         constant.SCREEN_WIDTH,
//         constant.SCREEN_HEIGHT,
//         0,
//     ) orelse {
//         err("Error creating window. SDL Error: {s}", .{c.SDL_GetError()});
//         return error.ERROR_CREATE_WINDOW;
//     };

//     self.renderer = c.SDL_CreateRenderer(self.window.?, -1, c.SDL_RENDERER_ACCELERATED) orelse {
//         err("Error creating renderer. SDL Error: {s}", .{c.SDL_GetError()});
//         return error.ERROR_CREATE_RENDERER;
//     };

//     self.state_machine = try allocator.create(StateMachine);
//     self.state_machine.* = StateMachine.init(allocator);

//     var start_state = try allocator.create(*StartState);
//     start_state.* = try StartState.init(allocator, self.window.?, self.renderer.?, self.state_machine);

//     try self.state_machine.changeState(&start_state.*.*.interface);
//     return self;
// }


package game

import "core:os"
import "core:fmt"
import sdl "vendor:sdl2"


WINDOW_WIDTH :: 640
WINDOW_HEIGHT :: 480
WINDOW_TITLE :: "Tetrio"
WINDOW_X :: sdl.WINDOWPOS_CENTERED
WINDOW_Y :: sdl.WINDOWPOS_CENTERED
WINDOW_FLAGS :: sdl.WindowFlags{.SHOWN}

Errno :: distinct i32
ERROR_NONE: Errno : 0
ERROR_INIT: Errno : 1

Game :: struct {
  window:        Maybe(^sdl.Window),
  renderer:      Maybe(^sdl.Renderer),
  state_machine: ^StateMachine,
  close:         proc(_: ^Game),
  loop:          proc(_: ^Game) -> Errno,
}

game_init :: proc() -> (^Game, Errno) {
  if status := sdl.Init(sdl.INIT_VIDEO | sdl.INIT_AUDIO); status < 0 {
    fmt.eprintf("ERROR: %s\n", sdl.GetErrorString())
    return nil, ERROR_INIT
  }

  self := &Game{close = close}
  self.window = sdl.CreateWindow(WINDOW_TITLE, WINDOW_X, WINDOW_Y, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_FLAGS)
  self.renderer = sdl.CreateRenderer(self.window.?, -1, {.ACCELERATED})
  self.state_machine = StateMachine.init()


  self.state_machine.changeState(&state_state)
  return self, ERROR_NONE
}


close :: proc(self: ^Game) {
  sdl.DestroyWindow(self.window.?)
  sdl.DestroyRenderer(self.renderer.?)
  sdl.Quit()
}


loop :: proc(self: ^Game) -> Errno {
  for {
    // self.fps_timer.startTimer();

    self.state_machine.input()
    self.state_machine.update()
    self.state_machine.render()

    // const time_taken = @intToFloat(f64, self.fps_timer.getTicks());
    // if (time_taken < constant.TICKS_PER_FRAME) {
    //     c.SDL_Delay(@floatToInt(u32, constant.TICKS_PER_FRAME - time_taken));
    // }
  }
}
