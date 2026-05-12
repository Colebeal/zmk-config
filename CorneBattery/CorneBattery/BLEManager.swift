import Foundation
import CoreBluetooth
import Combine

class BLEManager: NSObject, ObservableObject {
    @Published var leftBattery: Int?
    @Published var rightBattery: Int?
    @Published var isConnected = false

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var batteryCharacteristics: [CBCharacteristic] = []
    private var refreshTimer: Timer?

    private static let cacheURL: URL = {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("CorneBattery", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("levels.sh")
    }()

    static let batteryServiceUUID = CBUUID(string: "180F")
    static let batteryLevelUUID = CBUUID(string: "2A19")

    override init() {
        super.init()
        writeCache()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        // Poll every 5 minutes
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    private func writeCache() {
        let leftStr = leftBattery.map(String.init) ?? ""
        let rightStr = rightBattery.map(String.init) ?? ""
        let connected = isConnected ? "1" : "0"
        let ts = Int(Date().timeIntervalSince1970)
        let contents = "LEFT=\(leftStr)\nRIGHT=\(rightStr)\nCONNECTED=\(connected)\nUPDATED=\(ts)\n"
        try? contents.write(to: Self.cacheURL, atomically: true, encoding: .utf8)
    }

    func refresh() {
        // Try to read from already-discovered characteristics
        for characteristic in batteryCharacteristics {
            characteristic.service?.peripheral?.readValue(for: characteristic)
        }

        // If not connected, try to find the keyboard again
        if !isConnected {
            findKeyboard()
        }
    }

    private func findKeyboard() {
        guard centralManager.state == .poweredOn else { return }

        // First try to retrieve already-connected peripherals with Battery Service
        let connected = centralManager.retrieveConnectedPeripherals(withServices: [Self.batteryServiceUUID])
        for peripheral in connected {
            if peripheral.name?.lowercased().contains("corne") == true
                || peripheral.name?.lowercased().contains("blecorne") == true
                || peripheral.name?.lowercased().contains("zmk") == true {
                connectTo(peripheral)
                return
            }
        }

        // If no known peripheral found, try connecting to the first one with battery service
        if let peripheral = connected.first {
            connectTo(peripheral)
            return
        }

        // Fall back to scanning
        centralManager.scanForPeripherals(withServices: [Self.batteryServiceUUID], options: nil)
    }

    private func connectTo(_ peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            findKeyboard()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        connectTo(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        peripheral.discoverServices([Self.batteryServiceUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        leftBattery = nil
        rightBattery = nil
        batteryCharacteristics = []
        writeCache()

        // Reconnect after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.findKeyboard()
        }
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == Self.batteryServiceUUID {
            peripheral.discoverCharacteristics([Self.batteryLevelUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics where characteristic.uuid == Self.batteryLevelUUID {
            batteryCharacteristics.append(characteristic)
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.uuid == Self.batteryLevelUUID,
              let data = characteristic.value,
              let level = data.first else { return }

        let value = Int(level)

        DispatchQueue.main.async {
            // The first battery service is the left half (central)
            // The second is the right half (proxied peripheral)
            if let index = self.batteryCharacteristics.firstIndex(of: characteristic) {
                if index == 0 {
                    self.leftBattery = value
                } else {
                    self.rightBattery = value
                }
            }
            self.writeCache()
        }
    }
}
