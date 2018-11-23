//
//  DeviceVO.swift
//  MSA
//
//  Created by Andrey Krit on 11/18/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import CoreBluetooth
import RealmSwift

class DeviceVO: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var isConnected: Bool = false
    
    convenience init(_ model: CBPeripheral) {
        self.init()
        self.id = model.identifier.uuidString
        self.name = model.name ?? ""
        self.isConnected = model.state == .connected
        
    }
    
    convenience init(_ model: DeviceVO) {
        self.init()
        self.id = model.id
        self.name = model.name
        self.isConnected = model.isConnected
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
