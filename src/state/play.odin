package state

import "core:os"
import "core:fmt"
import "../game"
import "../util"
import "../config"
import sdl "vendor:sdl2"
import "vendor:sdl2/mixer"

CAPSCORE :: 100
STARTCOOLDOWNTIMER :: 1000

PlayState :: struct {
  using vtable:   StateInterface,
  window:         ^sdl.Window,
  renderer:       ^sdl.Renderer,
  state_machine:  ^StateMachine,
  level:          u32,
  score:          u32,
  internal_score: u32,
  cap_score:      u32,
  line:           u32,
  cap_timer:      ^util.Timer,
  font_info:      ^util.BitmapFont,
  drop_sound:     ^mixer.Chunk,
  clear_sound:    ^mixer.Chunk,
  bg_music:       ^mixer.Music,
  elements:       map[string]game.Entity,
  cooldown_timer: u32,
}


PlayState_init :: proc(w: ^sdl.Window, r: ^sdl.Renderer, sm: ^StateMachine) -> ^StateInterface {
  ps := new(PlayState)

  ps.vtable = {
    update  = update,
    render  = render,
    input   = input,
    stateID = stateID,
    onEnter = onEnter,
    onExit  = onExit,
    variant = ps,
  }

  ps.window = w
  ps.renderer = r
  ps.state_machine = sm

  ps.level = 1
  ps.score = 0
  ps.internal_score = 0
  ps.cap_score = CAPSCORE
  ps.line = 0
  ps.cap_timer = util.Timer_init()
  ps.font_info, _ = util.BitmapFont_init(r, "res/Futura.ttf", 25)
  ps.cooldown_timer = STARTCOOLDOWNTIMER

  ps.drop_sound = mixer.LoadWAV("res/drop.wav")

  if ps.drop_sound == nil {
    fmt.eprintf("Failed to load drop sound effect! SDL_mixer Error: %s\n", sdl.GetError())
    return nil
  }

  ps.clear_sound = mixer.LoadWAV("res/clear.wav")

  if ps.clear_sound == nil {
    fmt.eprintf("Failed to load clear sound effect! SDL_mixer Error: %s\n", sdl.GetError())
    return nil
  }

  ps.bg_music = mixer.LoadMUS("res/play.mp3")

  if ps.bg_music == nil {
    fmt.eprintf("Failed to load background music! SDL_mixer Error: %s\n", sdl.GetError())
    return nil
  }

  board := game.Board_init(ps.renderer)
  piece := game.randomPiece(ps.renderer, &ps.score, &ps.internal_score, &ps.cap_score, &ps.level, &ps.line, &ps.cooldown_timer)


  ps.elements = map[string]game.Entity {
    "board" = board,
    "piece" = piece,
  }

  return ps
}


@(private = "file")
update :: proc(self: ^StateInterface) {
  self, _ := self.variant.(^PlayState)

  piece := self.elements["piece"].(^game.Piece)
  board := self.elements["board"].(^game.Board)

  elapsed_time := self.cap_timer->getTicks()

  if (elapsed_time >= self.cooldown_timer) {
    if piece->moveDown(board, &self.elements, self.drop_sound, self.clear_sound) == false {
      game_over_state := GameoverState_init(self.window, self.renderer, self.state_machine, self)
      self.state_machine->pushState(game_over_state)
    }

    self.cap_timer->startTimer()
  }

  game.Piece_eraseLine(board)
}


@(private = "file")
render :: proc(self: ^StateInterface) {
  self, _ := self.variant.(^PlayState)
  sdl.SetRenderDrawColor(self.renderer, 0, 0, 0, 0)
  sdl.RenderClear(self.renderer)

  // Left viewport
  sdl.RenderSetViewport(self.renderer, &config.LeftViewport)
  sdl.SetRenderDrawColor(self.renderer, 0, 0, 0, 0)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = 360, h = config.WINDOW_HEIGHT})

  // Play viewport
  sdl.RenderSetViewport(self.renderer, &config.PlayViewport)
  sdl.SetRenderDrawColor(self.renderer, 0, 255, 0, 255)
  sdl.RenderDrawRect(self.renderer, &{x = 0, y = 0, w = 300, h = config.WINDOW_HEIGHT - config.BLOCK * 2})

  // Render the board and the tetromino
  piece := self.elements["piece"].(^game.Piece)
  board := self.elements["board"].(^game.Board)

  board->draw(game.View.PlayViewport)
  piece->draw(game.View.PlayViewport)

  // Right viewport
  sdl.RenderSetViewport(self.renderer, &config.RightViewport)
  sdl.SetRenderDrawColor(self.renderer, 0, 0, 0, 255)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  // Level viewport
  sdl.RenderSetViewport(self.renderer, &config.LevelViewport)
  sdl.SetRenderDrawColor(self.renderer, 255, 255, 255, 255)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  txt_width := self.font_info->calculateTextWidth("Level")
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 35, "Level", 255, 0, 0)

  level_txt := fmt.tprintf("%v", self.level)
  txt_width = self.font_info->calculateTextWidth(level_txt)
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 75, level_txt, 255, 0, 0)

  // Score viewport
  sdl.RenderSetViewport(self.renderer, &config.ScoreViewport)
  sdl.SetRenderDrawColor(self.renderer, 255, 255, 255, 255)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  txt_width = self.font_info->calculateTextWidth("Score")
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 35, "Score", 255, 0, 0)

  score_txt := fmt.tprintf("%v", self.score)
  txt_width = self.font_info->calculateTextWidth(score_txt)
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 75, score_txt, 255, 0, 0)

  // Line viewport
  sdl.RenderSetViewport(self.renderer, &config.LineViewport)
  sdl.SetRenderDrawColor(self.renderer, 0xFF, 0xFF, 0xFF, 0xFF)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  txt_width = self.font_info->calculateTextWidth("Line")
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 35, "Line", 255, 0, 0)

  line_txt := fmt.tprintf("%v", self.line)
  txt_width = self.font_info->calculateTextWidth(line_txt)
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 75, line_txt, 255, 0, 0)

  // Tetromino viewport
  sdl.RenderSetViewport(self.renderer, &config.TetrominoViewport)
  sdl.SetRenderDrawColor(self.renderer, 255, 255, 255, 255)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  // Draw next incoming piece
  game.NextPiece.?->draw(game.View.TetrominoViewport)

  sdl.RenderPresent(self.renderer)
}

@(private = "file")
input :: proc(self: ^StateInterface) -> bool {
  self, _ := self.variant.(^PlayState)

  piece := self.elements["piece"].(^game.Piece)
  board := self.elements["board"].(^game.Board)

  evt: sdl.Event

  for sdl.PollEvent(&evt) {

    #partial switch evt.type {
    case .QUIT:
      return false

    case .KEYDOWN:
      #partial switch evt.key.keysym.sym {
      case .ESCAPE:
        pause_state := PauseState_init(self.window, self.renderer, self.state_machine, self)
        self.state_machine->pushState(pause_state)

      case .SPACE:
        piece->hardDrop(board, &self.elements, self.drop_sound, self.clear_sound)

      case .UP, .W:
        if (evt.key.repeat == 0) {
          piece->rotate(board)
        }

      case .DOWN, .S:
        if piece->moveDown(board, &self.elements, self.drop_sound, self.clear_sound) == false {
          gameover_state := GameoverState_init(self.window, self.renderer, self.state_machine, self)
          self.state_machine->pushState(gameover_state)
        }

      case .LEFT, .A:
        piece->moveLeft(board)

      case .RIGHT, .D:
        piece->moveRight(board)
      }

    }
  }

  return true
}


@(private = "file")
stateID :: proc(self: ^StateInterface) -> string {
  return "Play"
}


@(private = "file")
onEnter :: proc(self: ^StateInterface) -> bool {
  self, _ := self.variant.(^PlayState)

  self.cap_timer->startTimer()

  if (mixer.PlayingMusic() == 0) {
    // Play the music
    mixer.PlayMusic(self.bg_music, -1)
  } else {
    // If the music is paused

    if (mixer.PausedMusic() == 1) {
      // Resume the music
      mixer.ResumeMusic()
    }
  }

  return true
}


@(private = "file")
onExit :: proc(self: ^StateInterface) -> bool {
  if mixer.PlayingMusic() != 0 {
    mixer.PauseMusic()
  }

  return true
}


@(private = "file")
close :: proc(self: ^PlayState) {
  sdl.DestroyWindow(self.window)
  sdl.DestroyRenderer(self.renderer)
  mixer.FreeChunk(self.drop_sound)
  mixer.FreeChunk(self.clear_sound)
}
