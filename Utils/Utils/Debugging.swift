//
//  Debugging.swift
//  Utils
//
//  Created by Dmitry Trimonov on 18/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation

public func currentTime() -> String {
    let timeString = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .long)
    return "[\(timeString)]"
}

public func log(_ message: String) {
    print("\(currentTime())\(message)")
}

/// The name/description of the current queue (Operation or Dispatch), if that can be found. Else, the name/description of the thread.
public func queueName() -> String {
    if let currentOperationQueue = OperationQueue.current {
        if let currentDispatchQueue = currentOperationQueue.underlyingQueue {
            return "dispatch queue: \(currentDispatchQueue.label.nonEmpty ?? currentDispatchQueue.description)"
        }
        else {
            return "operation queue: \(currentOperationQueue.name?.nonEmpty ?? currentOperationQueue.description)"
        }
    } else {
        let currentThread = Thread.current
        return "UNKNOWN QUEUE on thread: \(currentThread.name?.nonEmpty ?? currentThread.description)"
    }
}

public func logWithQueueInfo(_ message: String) {
    log("\(queueName()) \(message)")
}

extension String {

    /// Returns this string if it is not empty, else `nil`.
    public var nonEmpty: String? {
        if self.isEmpty {
            return nil
        }
        else {
            return self
        }
    }
}
