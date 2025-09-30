//
//  DebugLogger.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Centralized debug logging utility that prevents log spam and provides
//  controlled debug output. Includes rate limiting and log level management
//  for better performance and cleaner console output.
//
//  Review Date: September 30, 2025
//

import Foundation
import os.log

struct DebugLogger {
    
    // MARK: - Log Levels
    
    enum LogLevel: String, CaseIterable {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        
        var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .warning:
                return .default
            case .error:
                return .error
            }
        }
    }
    
    // MARK: - Rate Limiting
    
    private static var logCounts: [String: Int] = [:]
    private static var lastLogTimes: [String: Date] = [:]
    private static let maxLogsPerMinute = 10
    private static let logCooldown: TimeInterval = 60.0 // 1 minute
    
    // MARK: - Configuration
    
    private static let isDebugMode = false // Set to false for production
    private static let subsystem = "com.moneymanager.app"
    
    // MARK: - Logging Methods
    
    static func log(_ message: String, level: LogLevel = .debug, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        guard isDebugMode else { return }
        
        let logKey = "\(category)_\(function)_\(line)"
        
        // Rate limiting
        if shouldRateLimit(logKey: logKey) {
            return
        }
        
        // Create logger
        let logger = OSLog(subsystem: subsystem, category: category)
        
        // Format message
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "[\(level.rawValue)] \(fileName):\(line) \(function) - \(message)"
        
        // Log with appropriate level
        os_log("%{public}@", log: logger, type: level.osLogType, formattedMessage)
        
        // Update rate limiting counters
        updateRateLimit(logKey: logKey)
    }
    
    // MARK: - Convenience Methods
    
    static func debug(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    static func info(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    static func warning(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    static func error(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - Specialized Logging
    
    static func balanceCalculation(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: "BalanceCalculation", file: file, function: function, line: line)
    }
    
    static func performance(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: "Performance", file: file, function: function, line: line)
    }
    
    static func ui(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: "UI", file: file, function: function, line: line)
    }
    
    // MARK: - Rate Limiting Logic
    
    private static func shouldRateLimit(logKey: String) -> Bool {
        let now = Date()
        
        // Check if we've exceeded the rate limit
        if let count = logCounts[logKey], count >= maxLogsPerMinute {
            // Check if enough time has passed to reset the counter
            if let lastTime = lastLogTimes[logKey], now.timeIntervalSince(lastTime) < logCooldown {
                return true
            } else {
                // Reset the counter
                logCounts[logKey] = 0
            }
        }
        
        return false
    }
    
    private static func updateRateLimit(logKey: String) {
        let now = Date()
        
        // Update count
        logCounts[logKey, default: 0] += 1
        
        // Update last log time
        lastLogTimes[logKey] = now
        
        // Clean up old entries
        cleanupOldEntries()
    }
    
    private static func cleanupOldEntries() {
        let now = Date()
        let cutoffTime = now.addingTimeInterval(-logCooldown)
        
        // Remove old entries
        lastLogTimes = lastLogTimes.filter { $0.value > cutoffTime }
        
        // Remove corresponding count entries
        let validKeys = Set(lastLogTimes.keys)
        logCounts = logCounts.filter { validKeys.contains($0.key) }
    }
    
    // MARK: - Debug Utilities
    
    static func printMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let memoryUsage = info.resident_size / 1024 / 1024 // Convert to MB
            performance("Memory usage: \(memoryUsage) MB")
        }
    }
    
    static func printPerformanceMetrics() {
        performance("Performance metrics logged")
        printMemoryUsage()
    }
}
