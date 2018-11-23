//
//  HeartBeatDeviceViewModel.swift
//  MSA
//
//  Created by Andrey Krit on 11/13/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

protocol HeartBeatDevicePresenterProtocol {
    func start()
    func scanForDevices()
    func stopScanning()
    func makeNextPresenter(withDeviceAtIndex index: Int, view: HeartBeatDetailsViewProtocol) -> HeartBeatDetailsPresenterProtocol
}

class HeartBeatDevicePresenter: HeartBeatDevicePresenterProtocol  {
    
    let heartBeatService: HeartBeatManager
    weak var view: HeartBeatDeviceViewProtocol?
    
    var devices: [DeviceVO] = [] {
        didSet {
            if !devices.isEmpty { view?.hideLoader() }
                view?.reloadTableView()
        }
    }
    
    var filteredDevices: [DeviceVO] {
        let noNameDevices = devices.filter {$0.name.isEmpty}
        let namedDevices = devices.filter {!$0.name.isEmpty}.sorted {$0.name.lowercased() < $1.name.lowercased() }
        let allDevices = namedDevices + noNameDevices
        return allDevices.sorted(by: {$0.isConnected && !$1.isConnected})
    }
 
    var savedDevices: [DeviceVO] {
            let fetched = RealmManager.shared.getArray(ofType: DeviceVO.self)
            print(fetched)
            return fetched
    }
    
    init(view: HeartBeatDeviceViewProtocol, heartBeatService: HeartBeatManager) {
        self.view = view
        self.heartBeatService = heartBeatService
        self.heartBeatService.delegate = self
        print("BTPresenter inited")
    }
    
    func scanForDevices() {
        devices = []
        view?.showLoader()
        getConectedDevices()
        heartBeatService.scanForDevices()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.view?.hideLoader()
        }
    }
    
    func stopScanning() {
        heartBeatService.stopScaning()
    }
    
    func start() {
        
    }
    
    func makeNextPresenter(withDeviceAtIndex index: Int, view: HeartBeatDetailsViewProtocol) -> HeartBeatDetailsPresenterProtocol {
        let presenter = HeartBeatDetailsPresenter(view: view, heartBeatService: heartBeatService, device: filteredDevices[index])
        return presenter
    }
    
  
}

extension HeartBeatDevicePresenter: HeartBeatManagerDelegate {
    
    func deviceDidFailedToConnect(peripheral: CBPeripheral, error: Error?) {
        print("failed to connect")
    }
    
    func couldNotDiscoverServicesOrCharacteristics() {}
    
    
    func deviceDidConnected(peripheral: CBPeripheral) {
        view?.reloadTableView()
    }
    
    func deviceDidDisconnected() {
        view?.showAlert(title: "Отключение!", message: "Устройство отключено", action: nil)
    }
    
    
    func handleBluetooth(status: CBManagerState) {
        switch status {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            view?.showAlert(title: "Ошибка!", message: "Попробуйте еще раз", action: nil)
        case .unsupported:
            view?.showAlert(title: "Ошибка!", message: "Платформа не поддерживает данный формат соединения", action: nil)
        case .unauthorized:
            view?.showAlert(title: "Разрешите доступ", message: "Разрешите приложению доступ к Bluetooth для использования пульсометра", action: { self.goToSettings() })
        case .poweredOff:
            view?.showAlert(title: "Включите Bluetooth", message: "Включите Bluetooth на устройстве для использования пульсометра", action: nil)
        case .poweredOn:
            heartBeatService.scanForDevices()
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {[weak self] in
                self?.heartBeatService.stopScaning()
            }
        }
    }
    
    private func goToSettings() {
        guard let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL as URL, options: [:], completionHandler: nil)
        return
    }
    
    func getConectedDevices() {
        let connectedDevices = heartBeatService.getConnectedDevices()
        for connected in connectedDevices {
            print(connected.state)
            guard let _ = devices.first(where: { $0.id == connected.identifier.uuidString }) else {
                let newDevice = DeviceVO(connected)
                for savedDevice in savedDevices {
                    if newDevice.id == savedDevice.id {
                        newDevice.name = savedDevice.name
                    }
                }
                devices.append(newDevice)
                return
            }
        }
        
    }
    
    func deviceDetected(device: CBPeripheral) {
        guard let _ = devices.first(where: { $0.id == device.identifier.uuidString }) else {
            let newDevice = DeviceVO(device)
            print(savedDevices)
            for savedDevice in savedDevices {
                if newDevice.id == savedDevice.id {
                    newDevice.name = savedDevice.name
                }
            }
            devices.append(newDevice)
            return
        }
    }
}
