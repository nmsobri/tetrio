package state

import "core:c"
import "core:os"
import "core:fmt"
import "../util"
import "../game"
import "../config"
import sdl "vendor:sdl2"


StartState :: struct {
  using vtable:  StateInterface,
  window:        ^sdl.Window,
  renderer:      ^sdl.Renderer,
  state_machine: ^StateMachine,
  font_info:     ^util.BitmapFont,
  font_logo:     ^util.BitmapFont,
  font_credit:   ^util.BitmapFont,
  board:         ^game.Board,
}


StartState_init :: proc(w: ^sdl.Window, r: ^sdl.Renderer, sm: ^StateMachine) -> ^StartState {
  ss := new(StartState)

  ss.window = w
  ss.renderer = r
  ss.state_machine = sm

  ss.font_info, _ = util.BitmapFont_init(ss.renderer, "res/Futura.ttf", 25)
  ss.font_logo, _ = util.BitmapFont_init(ss.renderer, "res/Futura.ttf", 90)
  ss.font_credit, _ = util.BitmapFont_init(ss.renderer, "res/Futura.ttf", 15)

  ss.vtable = {
    update  = update,
    render  = render,
    input   = input,
    stateID = stateID,
    onEnter = onEnter,
    onExit  = onExit,
    variant = ss,
  }

  ss.board = game.Board_init(ss.renderer)

  return ss
}


@(private = "file")
update :: proc(self: ^StateInterface) {
}


@(private = "file")
render :: proc(self: ^StateInterface) {
  self, ok := self.variant.(^StartState)

  if !ok {
    fmt.eprintln("Not ^StartState")
    os.exit(1)
  }

  sdl.SetRenderDrawColor(self.renderer, 0x00, 0x00, 0x00, 0x00)
  sdl.RenderClear(self.renderer)

  // Left viewport
  sdl.RenderSetViewport(self.renderer, &config.LeftViewport)
  sdl.SetRenderDrawColor(self.renderer, 0x00, 0x00, 0x00, 0x00)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = 360, h = config.WINDOW_HEIGHT})

  // Play viewport
  sdl.RenderSetViewport(self.renderer, &config.PlayViewport)
  sdl.SetRenderDrawColor(self.renderer, 0x00, 0xFF, 0x00, 0xFF)
  sdl.RenderDrawRect(self.renderer, &{x = 0, y = 0, w = 300, h = config.WINDOW_HEIGHT - config.BLOCK * 2})

  self.board->draw(game.View.PlayViewport)

  txt_width := self.font_logo->calculateTextWidth("Tetrio")
  self.font_logo->renderText(cast(i32)((config.BLOCK * 10) - txt_width) / 2, 75, "Tetrio", 0, 200, 0)

  txt_width = self.font_info->calculateTextWidth("Press Enter To Play")
  self.font_info->renderText(cast(i32)((config.BLOCK * 10) - txt_width) / 2, 185, "Press Enter To Play", 0, 0, 255)

  txt_width = self.font_credit->calculateTextWidth("(C) Sobri 2021")
  self.font_credit->renderText(cast(i32)((config.BLOCK * 10) - txt_width) / 2, config.WINDOW_HEIGHT - 110, "(C) Sobri 2023", 0, 0, 0)

  // Right viewport
  sdl.RenderSetViewport(self.renderer, &config.RightViewport)
  sdl.SetRenderDrawColor(self.renderer, 0x00, 0x00, 0x00, 0xFF)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  // Level viewport
  sdl.RenderSetViewport(self.renderer, &config.LevelViewport)
  sdl.SetRenderDrawColor(self.renderer, 0xFF, 0xFF, 0xFF, 0xFF)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  txt_width = self.font_info->calculateTextWidth("Level")
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 35, "Level", 255, 0, 0)

  txt_width = self.font_info->calculateTextWidth("1")
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 75, "1", 255, 0, 0)

  // Score viewport
  sdl.RenderSetViewport(self.renderer, &config.ScoreViewport)
  sdl.SetRenderDrawColor(self.renderer, 0xFF, 0xFF, 0xFF, 0xFF)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  txt_width = self.font_info->calculateTextWidth("Score")
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 35, "Score", 255, 0, 0)

  txt_width = self.font_info->calculateTextWidth("0")
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 75, "0", 255, 0, 0)

  // Line viewport
  sdl.RenderSetViewport(self.renderer, &config.LineViewport)
  sdl.SetRenderDrawColor(self.renderer, 0xFF, 0xFF, 0xFF, 0xFF)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  txt_width = self.font_info->calculateTextWidth("Line")
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 35, "Line", 255, 0, 0)

  txt_width = self.font_info->calculateTextWidth("0")
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 75, "0", 255, 0, 0)

  // Tetromino viewport
  sdl.RenderSetViewport(self.renderer, &config.TetrominoViewport)
  sdl.SetRenderDrawColor(self.renderer, 0xFF, 0xFF, 0xFF, 0xFF)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  // Draw incoming piece
  // Piece.drawRandomPiece(self.renderer, Piece.View.TetrominoViewport)

  sdl.RenderPresent(self.renderer)
}


@(private = "file")
input :: proc(self: ^StateInterface) -> bool {
  self, ok := self.variant.(^StartState)

  if !ok {
    fmt.eprintln("Not ^StartState")
    os.exit(1)
  }

  evt: sdl.Event

  for sdl.PollEvent(&evt) {
    #partial switch (evt.type) {
    case .QUIT:
      return false
    case .KEYDOWN:
      #partial switch (evt.key.keysym.sym) {
      case .ESCAPE:
        return false
      case .RETURN:
        fmt.println("start::enter press")
        play_state := PlayState_init(self.window, self.renderer, self.state_machine)
        self.state_machine->changeState(play_state)
      }
    }
  }

  return true
}


@(private = "file")
stateID :: proc(self: ^StateInterface) -> string {
  return "Start"
}


@(private = "file")
onEnter :: proc(self: ^StateInterface) -> bool {
  return true
}


@(private = "file")
onExit :: proc(self: ^StateInterface) -> bool {
  return true
}
