
import Foundation

enum LogLevel: String {
    case error  = "[‼️]" // error
    case info   = "[ℹ️]" // info
    case debug  = "[💬]" // debug
    case verbos = "[🔬]" // verbose
    case warn   = "[⚠️]" // warning
    case severe  = "[🔥]" // severe
}

class Logger {

    private init() {}

    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }

    private static func logDate() -> String {
        return dateFormatter.string(from: Date())
    }

    static func log(_ message: Any,
                    event: LogLevel,
                    fileName: String = #file,
                    line: Int = #line,
                    function: String = #function) {

        #if DEBUG
            print("\(logDate()) [ORZ]\(event.rawValue)[\((fileName as NSString).lastPathComponent):\(line)] \(function) -> \(message)")
        #endif
    }
}
