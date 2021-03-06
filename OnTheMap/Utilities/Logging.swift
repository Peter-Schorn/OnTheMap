import Foundation

/// Wraps an object in a weak reference.
/// This is useful for creating an array of weak references.
public class WeakWrapper<T: AnyObject>: Hashable {
    
    /// - Warning: This function compares whether two references point to the
    ///       same object. It **DOES NOT** compare whether the wrapped objects are
    ///       the same because they are not required to conform to `Equatable`.
    public static func == <T>(lhs: WeakWrapper<T>, rhs: WeakWrapper<T>) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public weak var object: T?
    public let id = UUID()
    
    init(_ object: T) {
        self.object = object
    }
    
    
}


open class Logger: Equatable, Identifiable, Hashable {
    
    /// The type of the closure that determines
    /// how the log message is formatted.
    /// See `logMsgFormatter` `infoMsgFormatter`, `debugMsgFormatter`,
    /// `warningMsgFormatter`, `errorMsgFormatter`,
    /// and `criticalMsgFormatter`.
    public typealias LogMsgFormatter = (
        _ date: Date, _ label: String, _ level: Level,
        _ file: String, _ function: String, _ line: UInt,
        _ message: () -> String
    ) -> Void
    
    
    // prevent a strong reference cycle by holding an array of
    // weak references to each instance of Logger.
    private static var _allLoggers: [WeakWrapper<Logger>] = []
    
    /**
     All of the instances of this class.
    
     This is a computed property that wraps around an array
     of weak references to each instance. Only the instances
     that have not been deallocated will be returned.
     */
    open class var allLoggers: [Logger] {
        return _allLoggers.compactMap { $0.object }
    }
    
    /// Returns a logger based on its label.
    /// If multiple loggers with the same label exist,
    /// the first one found will be returned.
    open class subscript(_ label: String) -> Logger? {
        for logger in allLoggers {
            if logger.label == label {
                return logger
            }
        }
        
        return nil
    }
    
    
    /// Enables/disables all loggers.
    /// This variable **WILL** affect loggers created in the future.
    public static var allDisabled = false
    
    
    /// Sets the logging level for all **current** loggers.
    /// This function will not affect loggers created in the future.
    open class func setLevel(to level: Level) {
        for logger in allLoggers {
            logger.level = level
        }
    }
    
    
    final public class func == (lhs: Logger, rhs: Logger) -> Bool {
        return lhs.id == rhs.id
    }
    
    final public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /**
     Gets called when a message needs to
     be logged to determine how it is formatted
     and where the message is logged for **all** log levels.

     This is used when the formatter for a
     specific log level is left as nil (which is the default).
     
     The default is to print the message using the
     builtin print function,
     but you can customize how the message is logged.
     
     ```
     public typealias LogMsgFormatter = (
         _ date: Date, _ label: String, _ level: Levels,
         _ file: UInt, _ function: String, _ line: String,
         _ message: String
     ) -> Void
     ```
     
     See also `infoMsgFormatter`, `debugMsgFormatter`,
     `warningMsgFormatter`, `errorMsgFormatter`,
     and `criticalMsgFormatter`.
     */
    public var logMsgFormatter: LogMsgFormatter
    
    /// The formatter for customizing how
    /// info messages are formatted and where they are logged.
    /// If left nil (default), then `logMsgFormatter`
    /// will be used for formatting messages.
    /// See also `logMsgFormatter`.
    public var infoMsgFormatter: LogMsgFormatter? = nil
    /// The formatter for customizing how
    /// debug messages are formatted and where they are logged.
    /// If left nil (default), then `logMsgFormatter`
    /// will be used for formatting messages.
    /// See also `logMsgFormatter`.
    public var debugMsgFormatter: LogMsgFormatter? = nil
    /// The formatter for customizing how
    /// warning messages are formatted and where they are logged.
    /// If left nil (default), then `logMsgFormatter`
    /// will be used for formatting messages.
    /// See also `logMsgFormatter`.
    public var warningMsgFormatter: LogMsgFormatter? = nil
    /// The formatter for customizing how
    /// error messages are formatted and where they are logged.
    /// If left nil (default), then `logMsgFormatter`
    /// will be used for formatting messages.
    /// See also `logMsgFormatter`.
    public var errorMsgFormatter: LogMsgFormatter? = nil
    /// The formatter for customizing how
    /// critical messages are formatted and where they are logged.
    /// If left nil (default), then `logMsgFormatter`
    /// will be used for formatting messages.
    /// See also `logMsgFormatter`.
    public var criticalMsgFormatter: LogMsgFormatter? = nil
    
    /// Completely disbles all logging messages reglardless of level
    open var disabled: Bool
    /// A string identifying the log level.
    open var label: String
    /// The level of the logger. See `Level`
    open var level: Level
    public let id = UUID()
    
    public init(
        label: String,
        level: Level = .debug,
        disabled: Bool = false,
        logMsgFormatter: LogMsgFormatter? = nil
    ) {
        
        let formatter = logMsgFormatter ?? {
            date, label, level, file, function, line, message in
            
            print("[\(label): \(level): line \(line)] \(message())")
        }
        
        self.label = label
        self.level = level
        self.disabled = disabled
        self.logMsgFormatter = formatter
        Self._allLoggers.append(WeakWrapper(self))
    }
    
    deinit {
        Self._allLoggers.removeFirst { logger in
            logger.object == self
        }
        
    }
    
    /// Logs a message. Unless the log level is determined dynamically,
    /// you should normally use
    /// self.info, self.debug, self.warning, self.error, or self.critical
    /// to log a message at a given level.
    open func log(
        level: Level,
        _ message: @autoclosure @escaping () -> String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        guard !Self.allDisabled && !disabled && level >= self.level else {
            return
        }
        
        let formatter: LogMsgFormatter?
        
        switch level {
            case .info:
                formatter = infoMsgFormatter
            case .debug:
                formatter = debugMsgFormatter
            case .warning:
                formatter = warningMsgFormatter
            case .error:
                formatter = errorMsgFormatter
            case .critical:
                formatter = criticalMsgFormatter
        }
        
        // uw = unwrapped
        let uwFormatter = formatter ?? logMsgFormatter
        
        uwFormatter(
            Date(), label, level, file, function, line, message
        )
        
    }
    
    /// Logs an informational message.
    @inlinable
    open func info(
        _ message: @autoclosure @escaping () -> String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        self.log(
            level: .info, message(),
            file: file, function: function, line: line
        )
    }
    
    /// Logs a debugging message.
    @inlinable
    open func debug(
        _ message: @autoclosure @escaping () -> String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        self.log(
            level: .debug, message(),
            file: file, function: function, line: line
        )
    }
    
    /// Logs a warning message.
    @inlinable
    open func warning(
        _ message: @autoclosure @escaping () -> String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        self.log(
            level: .warning, message(),
            file: file, function: function, line: line
        )
    }
    
    /// Logs an error message.
    @inlinable
    open func error(
        _ message: @autoclosure @escaping () -> String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        self.log(
            level: .error, message(),
            file: file, function: function, line: line
        )
    }
    
    /// Logs a critical error message.
    @inlinable
    open func critical(
        _ message: @autoclosure @escaping () -> String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        self.log(
            level: .critical, message(),
            file: file, function: function, line: line
        )
    }
    
    
    /// The log level of the logger.
    public enum Level: Int, Comparable {
        
        case info
        case debug
        case warning
        case error
        case critical
        
        public static func < (lhs: Self, rhs: Self) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

    }
    
    
}
