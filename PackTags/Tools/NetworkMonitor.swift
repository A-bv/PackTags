//
//  NetworkMonitor.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 05/07/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import Foundation
import Network

@available(iOS 13.0, *)
final class NetworkMonitor: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied ? true : false
             }
        }
        monitor.start(queue: queue)
    }
}
