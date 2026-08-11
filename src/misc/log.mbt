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
fn _level_to_int(l : LogLevel) -> Int {
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
/// Logger state.
pub struct Logger {
  level : Ref[LogLevel]
  colorful : Ref[Bool]
}

///|
/// Create a new logger with default level INFO.
pub fn make_logger() -> Logger {
  { level: Ref(Info), colorful: Ref(true) }
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
pub fn shall_print(logger : Logger, l : LogLevel) -> Bool {
  _level_to_int(l) >= _level_to_int(logger.level.val)
}

///|
/// Format a log message.
pub fn format_msg(logger : Logger, l : LogLevel, msg : String) -> String {
  if shall_print(logger, l) {
    "\{level_to_str(l)} : \{msg}"
  } else {
    ""
  }
}
