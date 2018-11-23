//
//  HeartBeatDetailsPresenter.swift
//  MSA
//
//  Created by Andrey Krit on 11/14/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol  HeartBeatDetailsPresenterProtocol {
    func start()
    func makeAction()
    func save(newName: String?)
    
}

class HeartBeatDetailsPresenter: HeartBeatDetailsPresenterProtocol {
    
    let device: DeviceVO
    let heartBeatService: HeartBeatManager
    weak var view: HeartBeatDetailsViewProtocol?
    
    
    init(view: HeartBeatDetailsViewProtocol?, heartBeatService: HeartBeatManager, device: DeviceVO) {
        self.view = view
        self.device = device
        self.heartBeatService = heartBeatService
        self.heartBeatService.delegate = self
    }
    
    func start() {
        view?.setTitle(title: device.name)
        updateActionButton()
    }
    
    func makeAction() {
        if device.isConnected {
            heartBeatService.disconnect()
            UserDefaults.standard.removeObject(forKey: "lastTimeConnectedDevice")
            view?.moveBack()
        } else {
            heartBeatService.connectDevice(with: device.id)
        }
        
    }
    
    func save(newName: String?) {
        guard let name = newName else {
            view?.moveBack()
            return
        }
        device.name = name
        if !name.isEmpty {
            let newDevice = DeviceVO(device)
            RealmManager.shared.saveObject(newDevice)
        } else {
            var object: DeviceVO?
            object = RealmManager.shared.getElement(ofType: DeviceVO.self, filterWith: NSPredicate(format: "id = %@", self.device.id))
            guard let safeObject = object else { return }
                 RealmManager.shared.deleteObject(safeObject)
        }
        view?.moveBack()
        }
    
    
    
    private func updateActionButton() {
        device.isConnected ? view?.setActionButtonText(text: "Отключить") : view?.setActionButtonText(text: "Подключить")
    }
}

extension HeartBeatDetailsPresenter: HeartBeatManagerDelegate {
    
    func deviceDidConnected(peripheral: CBPeripheral) {
        device.isConnected = true
        view?.hideLoader()
        updateActionButton()
        
    }
    
    func handleBluetooth(status: CBManagerState) {}
    
    func deviceDetected(device: CBPeripheral) {}
    
    func couldNotDiscoverServicesOrCharacteristics() {
        DispatchQueue.main.async { [weak self] in
         self?.view?.showAlert(title: "Ошибка!", message: "Приложение не может подключиться к устройству. Проверьте устройство и попробуйте еще раз", action: nil)
        }
       
    }
    
    func deviceDidFailedToConnect(peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async { [weak self] in
        self?.view?.showAlert(title: "Ошибка!", message: "Приложение не может подключиться к устройству. Проверьте устройство и попробуйте еще раз", action: nil)
        }
    }
    
    func deviceDidDisconnected() {
        device.isConnected = false
         DispatchQueue.main.async { [weak self] in
         self?.view?.showAlert(title: "Отключение!", message: "Устройство отключено", action: nil)
        }
        updateActionButton()
    }
    
}
