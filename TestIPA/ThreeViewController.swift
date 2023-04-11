//
// ThreeViewController.swift
// SwiftTemplateApp
//
// Created by Xiaovv on 2022/8/15
//

import UIKit
import Network

class ThreeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        wakeOnLAN(macAddress: "24:5E:BE:69:40:99")
    }
    
    
    func wakeOnLAN(macAddress: String) {
        // 将 MAC 地址转换为字节数组
        let macBytes = macAddress.split(separator: ":").compactMap { UInt8($0, radix: 16) }
        var macAddressBytes = [UInt8](repeating: 0xff, count: 6) + Array(repeating: macBytes, count: 16).flatMap { $0 }
        
        // 获取本地网络的广播地址
        guard let broadcastAddress = getBroadcastAddress() else {
            print("Could not determine broadcast address")
            return
        }
        
        // 创建 UDP 套接字并发送 WOL 包
        let queue = DispatchQueue(label: "WakeOnLAN")
        
        guard let port = NWEndpoint.Port(rawValue: 9) else {
            return
        }
        let connection = NWConnection(host: NWEndpoint.Host(broadcastAddress), port: port, using: .udp)
        connection.stateUpdateHandler = { (newState) in
            switch(newState) {
            case .ready:
                print("Sending WOL packet...")
                
                let content = Data(macAddressBytes)
                connection.send(content: content, completion: .idempotent)
            case .failed(let error):
                print("Could not connect to network: \(error)")
            default:
                break
            }
        }
        connection.start(queue: queue)
    }
    
    // 获取本地网络的广播地址
    func getBroadcastAddress() -> String? {
        var broadcastAddress: String?
        var ifaddrPointer: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddrPointer) == 0 else { return nil }
        defer { freeifaddrs(ifaddrPointer) }
        
        while let ifaddr = ifaddrPointer?.pointee {
            if ifaddr.ifa_flags & UInt32(IFF_BROADCAST) != 0 && ifaddr.ifa_addr != nil {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                
                let _ = ifaddr.ifa_addr.withMemoryRebound(to: sockaddr_storage.self, capacity: 1) { pointer in
                    
                    var addr = pointer
                    switch Int32(addr.pointee.ss_family) {
                    case AF_INET:
                        // IPv4 address
                        var ipv4Addr = withUnsafePointer(to: &addr) {
                            $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                                $0.pointee.sin_addr
                            }
                        }
                        inet_ntop(AF_INET, &ipv4Addr, &hostname, socklen_t(hostname.count))
                        broadcastAddress = String(cString: hostname)
                        
                    case AF_INET6:
                        // IPv6 address
                        var ipv6Addr = withUnsafePointer(to: &addr) {
                            $0.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) {
                                $0.pointee.sin6_addr
                            }
                        }
                        inet_ntop(AF_INET6, &ipv6Addr, &hostname, socklen_t(hostname.count))
                        broadcastAddress = String(cString: hostname)
                        
                    default:
                        // Unknown address family
                        break
                    }
                }
                
                
            }
            ifaddrPointer = ifaddr.ifa_next
        }
        
        return broadcastAddress
    }
}
