package state

import "../config"
import "../game"
import "../util"
import "core:os"
import "core:fmt"
import sdl "vendor:sdl2"
import "vendor:sdl2/mixer"


GameoverState :: struct {
  using vtable:  StateInterface,
  window:        ^sdl.Window,
  renderer:      ^sdl.Renderer,
  state_machine: ^StateMachine,
  play_state:    ^PlayState,
  font_info:     ^util.BitmapFont,
}


GameoverState_init :: proc(w: ^sdl.Window, r: ^sdl.Renderer, sm: ^StateMachine, play_state: ^PlayState) -> ^StateInterface {
  gos := new(GameoverState)

  gos.vtable = {
    update  = update,
    render  = render,
    input   = input,
    stateID = stateID,
    onEnter = onEnter,
    onExit  = onExit,
    variant = gos,
  }

  gos.window = w
  gos.renderer = r
  gos.state_machine = sm
  gos.play_state = play_state
  gos.font_info, _ = util.BitmapFont_init(gos.renderer, "res/Futura.ttf", 25)

  return gos
}


@(private = "file")
update :: proc(self: ^StateInterface) {
}


@(private = "file")
render :: proc(self: ^StateInterface) {
  self, _ := self.variant.(^GameoverState)

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

  board, _ := self.play_state.elements["board"].(^game.Board)
  board->draw(game.View.PlayViewport)

  txt_width := self.font_info->calculateTextWidth("Game Over!")
  self.font_info->renderText((config.PlayViewport.w / 2) - cast(i32)txt_width / 2, (config.PlayViewport.h / 2) - cast(i32)self.font_info->getGlyphHeight(), "Game Over!", 0, 0, 255)

  // Right viewport
  sdl.RenderSetViewport(self.renderer, &config.RightViewport)
  sdl.SetRenderDrawColor(self.renderer, 0, 0, 0, 255)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  // Level viewport
  sdl.RenderSetViewport(self.renderer, &config.LevelViewport)
  sdl.SetRenderDrawColor(self.renderer, 255, 255, 255, 255)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  txt_width = self.font_info->calculateTextWidth("Level")
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 35, "Level", 255, 0, 0)

  level_txt := fmt.tprintf("%v", self.play_state.level)
  txt_width = self.font_info->calculateTextWidth(level_txt)
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 75, level_txt, 255, 0, 0)

  // Score viewport
  sdl.RenderSetViewport(self.renderer, &config.ScoreViewport)
  sdl.SetRenderDrawColor(self.renderer, 255, 255, 255, 255)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  txt_width = self.font_info->calculateTextWidth("Score")
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 35, "Score", 255, 0, 0)

  score_txt := fmt.tprintf("%v", self.play_state.score)
  txt_width = self.font_info->calculateTextWidth(score_txt)
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 75, score_txt, 255, 0, 0)

  // Line viewport
  sdl.RenderSetViewport(self.renderer, &config.LineViewport)
  sdl.SetRenderDrawColor(self.renderer, 255, 255, 255, 255)
  sdl.RenderFillRect(self.renderer, &{x = 0, y = 0, w = config.BLOCK * 6, h = config.WINDOW_HEIGHT})

  txt_width = self.font_info->calculateTextWidth("Line")
  self.font_info->renderText(cast(i32)(config.VIEWPORT_INFO_WIDTH - txt_width) / 2, 35, "Line", 255, 0, 0)

  line_txt := fmt.tprintf("%v", self.play_state.line)
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
  self, _ := self.variant.(^GameoverState)

  evt: sdl.Event
  for sdl.PollEvent(&evt) {

    #partial switch evt.type {
    case .QUIT:
      return false

    case .KEYDOWN:
      #partial switch evt.key.keysym.sym {
      case .ESCAPE:
        return false
      case .RETURN:
        // Pop game over state
        self.state_machine->popState()
        play_state := PlayState_init(self.window, self.renderer, self.state_machine)
        self.state_machine->changeState(play_state)
      }
    }
  }

  return true
}

@(private = "file")
stateID :: proc(self: ^StateInterface) -> string {
  return "GameOver"
}


@(private = "file")
onEnter :: proc(self: ^StateInterface) -> bool {
  return true
}


@(private = "file")
onExit :: proc(self: ^StateInterface) -> bool {
  return true
}


@(private = "file")
close :: proc(self: ^PlayState) {
}
