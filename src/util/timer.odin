package util

import sdl "vendor:sdl2"

Timer :: struct {
  is_started:  bool,
  is_paused:   bool,
  start_timer: u32,
  pause_timer: u32,
  startTimer:  proc(self: ^Timer),
  stopTimer:   proc(self: ^Timer),
  pauseTimer:  proc(self: ^Timer),
  resumeTimer: proc(self: ^Timer),
  getTicks:    proc(self: ^Timer) -> u32,
  isStarted:   proc(self: ^Timer) -> bool,
  isPaused:    proc(self: ^Timer) -> bool,
}

Timer_init :: proc() -> ^Timer {
  t := new(Timer)

  t.is_started = false
  t.is_paused = false
  t.start_timer = 0
  t.pause_timer = 0

  t.startTimer = _startTimer
  t.stopTimer = _stopTimer
  t.pauseTimer = _pauseTimer
  t.resumeTimer = _resumeTimer
  t.getTicks = _getTicks
  t.isStarted = _isStarted
  t.isPaused = _isPaused

  return t
}

_startTimer :: proc(self: ^Timer) {
  self.start_timer = sdl.GetTicks()
  self.pause_timer = 0
  self.is_started = true
  self.is_paused = false
}

_stopTimer :: proc(self: ^Timer) {
  self.is_started = false
  self.is_paused = false
  self.start_timer = 0
  self.pause_timer = 0
}

_pauseTimer :: proc(self: ^Timer) {
  if self.is_started && !self.is_paused {
    self.is_paused = true
    self.start_timer = 0
    // Since time is static here ( due to pause ), we need to calculate
    // how much time has passed before time become static ( paused )
    self.pause_timer = sdl.GetTicks() - self.start_timer
  }
}

_resumeTimer :: proc(self: ^Timer) {
  if self.is_started && self.is_paused {
    self.is_paused = false
    self.start_timer = sdl.GetTicks() - self.pause_timer
    self.pause_timer = 0
  }
}

_getTicks :: proc(self: ^Timer) -> u32 {
  if !self.is_started do return 0

  if self.is_paused {
    return self.pause_timer
  } else {
    return sdl.GetTicks() - self.start_timer
  }
}

_isStarted :: proc(self: ^Timer) -> bool {
  return self.is_started
}

_isPaused :: proc(self: ^Timer) -> bool {
  return self.is_paused
}
