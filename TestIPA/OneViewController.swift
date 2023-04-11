//
// OneViewController.swift
// SwiftTemplateApp
//
// Created by Xiaovv on 2022/8/15
//

import UIKit
import Foundation
import CocoaAsyncSocket

class OneViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 示例，唤醒 MAC 地址为 00:11:22:33:44:55 的主机
        wakeOnLan(macAddress: "00:11:22:33:44:55")
    }
    
    
    func wakeOnLan(macAddress: String) {
        // 通过 MAC 地址计算出唤醒包
        let macBytes = macAddress.split(separator: ":").map { String($0) }.map { UInt8($0, radix: 16)! }
        var macAddressBytes = [UInt8](repeating: 0, count: 16 * macBytes.count)
        for i in 0..<macBytes.count {
            for j in 0..<16 {
                macAddressBytes[i * 16 + j] = j < 6 ? 0xFF : macBytes[i]
            }
        }
        // 使用 UDP 发送唤醒包
        let sock = try! GCDAsyncUdpSocket(delegate: nil, delegateQueue: DispatchQueue.main)
        try! sock.enableBroadcast(true)
        sock.send(Data(macAddressBytes), toHost: "255.255.255.255", port: 9, withTimeout: -1, tag: 0)
    }
    
    

}
