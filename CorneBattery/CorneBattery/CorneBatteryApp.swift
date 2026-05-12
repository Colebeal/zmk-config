import SwiftUI
import AppKit
import Combine

@main
struct CorneBatteryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var bleManager: BLEManager!
    var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        bleManager = BLEManager()

        // Update menu bar whenever battery changes
        Publishers.CombineLatest3(
            bleManager.$leftBattery,
            bleManager.$rightBattery,
            bleManager.$isConnected
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] _, _, _ in
            self?.updateStatusBar()
            self?.buildMenu()
        }
        .store(in: &cancellables)

        updateStatusBar()
        buildMenu()
    }

    func updateStatusBar() {
        guard let button = statusItem.button else { return }

        let attributed = NSMutableAttributedString()

        let font = NSFont(name: "SourceCodePro-Medium", size: 12.5)
            ?? NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .medium)
        let boldFont = NSFont(name: "SourceCodePro-Bold", size: 12.5)
            ?? NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .bold)

        let baseAttrs: [NSAttributedString.Key: Any] = [.font: font]

        let dimAttrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.labelColor.withAlphaComponent(0.7)
        ]

        // Left half
        attributed.append(NSAttributedString(string: "L: ", attributes: dimAttrs))
        let leftText = bleManager.leftBattery.map { "\($0)%" } ?? "--"
        let leftColor = batteryNSColor(bleManager.leftBattery)
        attributed.append(NSAttributedString(string: leftText, attributes: [
            .font: boldFont,
            .foregroundColor: leftColor
        ]))

        attributed.append(NSAttributedString(string: "   ", attributes: baseAttrs))

        // Right half
        attributed.append(NSAttributedString(string: "R: ", attributes: dimAttrs))
        let rightText = bleManager.rightBattery.map { "\($0)%" } ?? "--"
        let rightColor = batteryNSColor(bleManager.rightBattery)
        attributed.append(NSAttributedString(string: rightText, attributes: [
            .font: boldFont,
            .foregroundColor: rightColor
        ]))

        button.attributedTitle = attributed
    }

    func buildMenu() {
        let menu = NSMenu()

        let leftLevel = bleManager.leftBattery.map { "\($0)%" } ?? "--"
        let rightLevel = bleManager.rightBattery.map { "\($0)%" } ?? "--"

        let leftItem = NSMenuItem(title: "Left half:  \(leftLevel)", action: nil, keyEquivalent: "")
        let rightItem = NSMenuItem(title: "Right half: \(rightLevel)", action: nil, keyEquivalent: "")
        leftItem.isEnabled = false
        rightItem.isEnabled = false

        menu.addItem(leftItem)
        menu.addItem(rightItem)
        menu.addItem(.separator())

        let status = bleManager.isConnected ? "Connected" : "Searching..."
        let statusItem = NSMenuItem(title: status, action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(refresh), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        self.statusItem.menu = menu
    }

    func batteryNSColor(_ level: Int?) -> NSColor {
        guard let level else { return .secondaryLabelColor }
        switch level {
        case 51...100: return .systemGreen
        case 21...50: return .systemYellow
        default: return .systemRed
        }
    }

    @objc func refresh() {
        bleManager.refresh()
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
