//
//  NetworkMonitor.swift
//  hungrynow
//
//  Concrete implementation of NetworkMonitorProtocol using NWPathMonitor.
//

import Foundation
import Network

final class NetworkMonitor: NetworkMonitorProtocol {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.revaiter.hungrynow.networkmonitor", qos: .background)
    private let lock = NSLock()
    private var _isConnected: Bool = true

    var isConnected: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isConnected
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            self.lock.lock()
            self._isConnected = (path.status == .satisfied)
            self.lock.unlock()
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
