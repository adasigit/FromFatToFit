//
//  BluetoothManager.swift
//  FromFatToFit
//
//  Created by Sigit Academy on 27/05/24.
//

import CoreBluetooth
import os

class BluetoothManager: NSObject, CBPeripheralManagerDelegate {
    
    var connectedCentral: CBCentral?
    var peripheralManager: CBPeripheralManager!
    var transferCharacteristic: CBMutableCharacteristic?
    
    var menuScene: MenuScene!
    var gameScene: GameScene!
    
    init(menuscene: MenuScene, gamescene: GameScene){
        super.init()
        menuScene = menuscene
        gameScene = gamescene
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
    }
    
    
    internal func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        switch peripheral.state {
        case .poweredOn:
            // ... so start working with the peripheral
            os_log("CBManager is powered on")
            setupPeripheral()
        case .poweredOff:
            os_log("CBManager is not powered on")
            // In a real app, you'd deal with all the states accordingly
            return
        case .resetting:
            os_log("CBManager is resetting")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unauthorized:
            // In a real app, you'd deal with all the states accordingly
            if #available(iOS 13.0, *) {
                switch peripheral.authorization {
                case .denied:
                    os_log("You are not authorized to use Bluetooth")
                case .restricted:
                    os_log("Bluetooth is restricted")
                default:
                    os_log("Unexpected authorization")
                }
            } else {
                // Fallback on earlier versions
            }
            return
        case .unknown:
            os_log("CBManager state is unknown")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unsupported:
            os_log("Bluetooth is not supported on this device")
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            os_log("A previously unknown peripheral manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }
    
    /*
     *  Catch when someone subscribes to our characteristic, then start sending them data
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        os_log("Central subscribed to characteristic")
        
        menuScene.statuslabel.text = "Bluetooth connected"

        
        //        // Get the data
        //        dataToSend = textView.text.data(using: .utf8)!
        //
        //        // Reset the index
        //        sendDataIndex = 0
        
        // save central
        connectedCentral = central
        
        // Start sending
        //        sendData()
    }
    
    /*
     * This callback comes in when the PeripheralManager received write to characteristics
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for aRequest in requests {
            guard let requestValue = aRequest.value,
                  let stringFromData = String(data: requestValue, encoding: .utf8) else {
                continue
            }
            
            os_log("Received write request of %d bytes: %s", requestValue.count, stringFromData)
            
            switch stringFromData {
            case "1":
                menuScene.vc.presentGame(.normal)
            case "2":
                menuScene.vc.presentGame(.continous)
            case "3":
                gameScene.pause()
            case "4":
                gameScene.end()
            default:
                break
            }
        }
    }
    
    private func setupPeripheral() {
        
        // Build our service.
        os_log("setupPeripheral")
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [TransferService.serviceUUID]])

        
        // Start with the CBMutableCharacteristic.
        let transferCharacteristic = CBMutableCharacteristic(type: TransferService.characteristicUUID,
                                                             properties: [.notify, .writeWithoutResponse],
                                                             value: nil,
                                                             permissions: [.readable, .writeable])
        
        // Create a service from the characteristic.
        let transferService = CBMutableService(type: TransferService.serviceUUID, primary: true)
        
        // Add the characteristic to the service.
        transferService.characteristics = [transferCharacteristic]
        
        // And add it to the peripheral manager.
        peripheralManager.add(transferService)
        
        // Save the characteristic for later.
        self.transferCharacteristic = transferCharacteristic
        
    }
    
    
}
