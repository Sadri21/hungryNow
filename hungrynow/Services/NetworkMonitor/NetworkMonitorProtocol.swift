//
//  NetworkMonitorProtocol.swift
//  hungrynow
//
//  Protocol abstraction for network reachability monitoring.
//  Enables ViewModel dependency inversion per the project's one rule that matters.
//

import Foundation

protocol NetworkMonitorProtocol: AnyObject {
    /// True when an active network connection (Wi-Fi or cellular) is satisfied.
    var isConnected: Bool { get }
}
