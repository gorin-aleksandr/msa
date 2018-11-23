//
//  HeartBeatManager.swift
//  MSA
//
//  Created by Andrey Krit on 10/21/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol HeartBeatDelegate: class {
    func heartBitDidReceived(_ value: Int)
}

protocol HeartBeatManagerDelegate: class {
    func handleBluetooth(status: CBManagerState)
    func deviceDetected(device: CBPeripheral)
    func deviceDidFailedToConnect(peripheral: CBPeripheral, error: Error?)
    func deviceDidConnected(peripheral: CBPeripheral)
    func couldNotDiscoverServicesOrCharacteristics()
    func deviceDidDisconnected()
}

class HeartBeatManager: NSObject {

    var availableDevices: [CBPeripheral] = []
    var heartRatePeripheral: CBPeripheral!
    
    var centralManager: CBCentralManager!
    let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    
    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
    let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")
    var isDisconnectedWhileTryingToConnect = false
    weak var heartBeatDelegate: HeartBeatDelegate?
    weak var delegate: HeartBeatManagerDelegate?
    
    override init() {
        super.init()
        print("manager inited")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanForDevices() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [], options: nil)
        }
        
    }
    
    func stopScaning() {
        centralManager.stopScan()
    }
    
    deinit {
        print("BTMAnager deinited")
    }
}

extension HeartBeatManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.handleBluetooth(status: central.state)
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
//            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        //heartRatePeripheral = peripheral
        availableDevices.append(peripheral)
        delegate?.deviceDetected(device: peripheral)
        let data = (advertisementData as! NSDictionary).value(forKey: "kCBAdvDataLocalName") as? String
        //heartRatePeripheral.delegate = self
        //centralManager.stopScan()
        //centralManager.connect(heartRatePeripheral, options: nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        heartRatePeripheral = peripheral
        heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        isDisconnectedWhileTryingToConnect = true
        delegate?.deviceDidFailedToConnect(peripheral: peripheral, error: error)
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("restoring")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print(error)
        print(heartRatePeripheral)
        if !isDisconnectedWhileTryingToConnect {
            delegate?.deviceDidDisconnected()
        }
        
    }
    
    
}

extension HeartBeatManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services, !services.isEmpty else {
            isDisconnectedWhileTryingToConnect = true
            disconnect()
            delegate?.couldNotDiscoverServicesOrCharacteristics()
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else {
            isDisconnectedWhileTryingToConnect = true
            disconnect()
            delegate?.couldNotDiscoverServicesOrCharacteristics()
            return }
        delegate?.deviceDidConnected(peripheral: peripheral)
        saveConnectedDeviceId(id: peripheral.identifier.uuidString)
        isDisconnectedWhileTryingToConnect = false
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        switch characteristic.uuid {
//        case bodySensorLocationCharacteristicCBUUID:
//            let bodySensorLocation = bodyLocation(from: characteristic)
//            print(bodySensorLocation)
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
//    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
//        guard let characteristicData = characteristic.value,
//            let byte = characteristicData.first else { return "Error" }
//
//        switch byte {
//        case 0: return "Other"
//        case 1: return "Chest"
//        case 2: return "Wrist"
//        case 3: return "Finger"
//        case 4: return "Hand"
//        case 5: return "Ear Lobe"
//        case 6: return "Foot"
//        default:
//            return "Reserved for future use"
//        }
//    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
    
   func onHeartRateReceived(_ value: Int){
        print(value)
        heartBeatDelegate?.heartBitDidReceived(value)
    }
    
    func connectDevice(with id: String) {
        centralManager.stopScan()
        if let deviceToConnect = availableDevices.first(where: {$0.identifier.uuidString == id}) {
            deviceToConnect.delegate = self
            centralManager.connect(deviceToConnect, options: nil)
        } else {
            delegate?.couldNotDiscoverServicesOrCharacteristics()
        }
        
    }
    
    func getConnectedDevices() -> [CBPeripheral] {
        return centralManager.retrieveConnectedPeripherals(withServices: [heartRateServiceCBUUID])
        
    }
    
    func disconnect() {
        guard let device = heartRatePeripheral else { return }
        centralManager.cancelPeripheralConnection(device)
        heartRatePeripheral = nil
    }
    
    private func saveConnectedDeviceId(id: String) {
        UserDefaults.standard.setValue(id, forKey: "lastTimeConnectedDevice")
    }
}


