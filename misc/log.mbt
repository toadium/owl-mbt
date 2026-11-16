///|
/// Log level.
pub enum LogLevel {
  Debug
  Info
  Warn
  Error
  Fatal
}

///|
/// Convert log level to integer for comparison.
fn _level_to_int(l : LogLevel) -> Int32 {
  match l {
    Debug => 0
    Info => 1
    Warn => 2
    Error => 3
    Fatal => 4
  }
}

///|
/// Convert log level to string.
pub fn level_to_str(l : LogLevel) -> String {
  match l {
    Debug => "DEBUG"
    Info => "INFO"
    Warn => "WARN"
    Error => "ERROR"
    Fatal => "FATAL"
  }
}

///|
/// Public constructors for LogLevel.
pub fn level_debug() -> LogLevel {
  Debug
}

///|
pub fn level_info() -> LogLevel {
  Info
}

///|
pub fn level_warn() -> LogLevel {
  Warn
}

///|
pub fn level_error() -> LogLevel {
  Error
}

///|
pub fn level_fatal() -> LogLevel {
  Fatal
}

///|
/// Logger state. When `colorful` is enabled, `format_msg` wraps the level
/// word in ANSI color codes (the message body stays uncolored).
pub struct Logger {
  level : Ref[LogLevel]
  colorful : Ref[Bool]
}

///|
/// Create a new logger with default level INFO.
pub fn make_logger() -> Logger {
  { level: Ref(Info), colorful: Ref(true), }
}

///|
/// Set the log level.
pub fn set_level(logger : Logger, l : LogLevel) -> Unit {
  logger.level.val = l
}

///|
/// Set colorful output.
pub fn set_colorful(logger : Logger, b : Bool) -> Unit {
  logger.colorful.val = b
}

///|
/// Check if a message at the given level should be printed.
pub fn should_print(logger : Logger, l : LogLevel) -> Bool {
  _level_to_int(l) >= _level_to_int(logger.level.val)
}

///|
/// ANSI color code for each log level (used for colorful output).
fn _level_color(l : LogLevel) -> String {
  match l {
    Debug => "\u{1b}[36m"
    Info => "\u{1b}[32m"
    Warn => "\u{1b}[33m"
    Error => "\u{1b}[31m"
    Fatal => "\u{1b}[35m"
  }
}

///|
/// Format a log message. When `colorful` is enabled, the level word is
/// wrapped in ANSI color codes; the message body is left uncolored.
pub fn format_msg(logger : Logger, l : LogLevel, msg : String) -> String {
  if should_print(logger, l) {
    if logger.colorful.val {
      "\{_level_color(l)}\{level_to_str(l)}\u{1b}[0m : \{msg}"
    } else {
      "\{level_to_str(l)} : \{msg}"
    }
  } else {
    ""
  }
}
