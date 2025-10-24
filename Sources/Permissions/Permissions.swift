import SwiftUI
import CoreBluetooth
import Contacts
import AVFoundation
import CoreLocation
import UserNotifications
import Photos
import Combine

public protocol PermissionsLocalizationProvider {
    /// A Short Title for the Permission, e.g. "Microphone"
    func makeLocalizedTitle(for type: PermissionType) -> LocalizedStringKey
    /// A Descriptive Text explaining the user what the given Permission grants your App access to
    func makeLocalizedDescription(for type: PermissionType) -> LocalizedStringKey
    /// The header to display on top of Permissions in the Permission Sheet, Default: "This App Requires Access to"
    var sheetHeader: LocalizedStringKey { get set }
    /// The Title to display when setup has completed in the Permission Sheet, Default: "All Set!"
    var allSetTitle: LocalizedStringKey { get set }
    /// The Description to display when setup has completed in the Permission Sheet, Default: "Tap Done below to start using this App"
    var allSetDescription: LocalizedStringKey { get set }
    /// The Text to Display when a Permission is granted
    var grantedTitle: LocalizedStringKey { get set }
    /// The Text to Display when a Permission is not granted
    var notGrantedTitle: LocalizedStringKey { get set }
    /// The Grant Buttons Title
    var grantButtonTitle: LocalizedStringKey { get set }
    /// The Continue Buttons Title
    var continueButtonTitle: LocalizedStringKey { get set }
    /// The Done Buttons Title
    var doneButtonTitle: LocalizedStringKey { get set }
    /// The Text to display while waiting
    var waitingTitle: LocalizedStringKey { get set }
    /// The "Tap Here to Skip" Buttons Title, its displayed below the skipNoticeText
    var tapHereToSkipButtonTitle: LocalizedStringKey { get set }
    /// The Skip Notice, by default: "If you do not want to grant this Permission, you can"
    var skipNoticeText: LocalizedStringKey { get set }
    /// The "Help" Sheet Title Header
    var helpNavigationTitle: LocalizedStringKey { get set }
    /// The "What does this Permission do?" Title of the Section in the Help Sheet
    var whatDoesThisPermissionDoSectionTitle: LocalizedStringKey { get set }
    /// The "Permissions" Title shown in the Sheet
    var permissionsTitle: LocalizedStringKey { get set }
    /// The "I can't grant this Permission!" Title shown in the Sheet
    var cantGrantSectionTitle: LocalizedStringKey { get set }
    /// The Help Text for the cantGrantSectionTitle Section, by default:
    var cantGrantHelpText: LocalizedStringKey { get set }
    /// The "Need Help?" Buttons Title
    var needHelpButtonTitle: LocalizedStringKey { get set }
}

public extension PermissionsLocalizationProvider where Self == DefaultPermissionsLocalizationProvider {
    static var defaultProvider: PermissionsLocalizationProvider { DefaultPermissionsLocalizationProvider() }
}

public struct DefaultPermissionsLocalizationProvider: PermissionsLocalizationProvider {
    public var needHelpButtonTitle: LocalizedStringKey = "Need help?"
    
    public var cantGrantHelpText: LocalizedStringKey = "Don't worry! This usally happens when the Permission Prompt was dismissed too early or you declined this Permission before, tap this Message to open Settings and Grant the Permission manually there"
    
    public var cantGrantSectionTitle: LocalizedStringKey = "I can't grant this Permission!"
    
    public var permissionsTitle: LocalizedStringKey = "Permissions"
    
    public var whatDoesThisPermissionDoSectionTitle: LocalizedStringKey = "What does this Permission do?"
    
    public var helpNavigationTitle: LocalizedStringKey = "Help"
    
    public var tapHereToSkipButtonTitle: LocalizedStringKey = "Tap here to Skip"
    
    public var skipNoticeText: LocalizedStringKey = "If you do not want to grant this Permission, you can"
    
    public var grantButtonTitle: LocalizedStringKey = "Grant"
    
    public var continueButtonTitle: LocalizedStringKey = "Continue"
    
    public var doneButtonTitle: LocalizedStringKey = "Done"
    
    public var waitingTitle: LocalizedStringKey = "Waiting"
    
    public var grantedTitle: LocalizedStringKey = "Granted"
    
    public var notGrantedTitle: LocalizedStringKey = "Not Granted"
    
    public var allSetDescription: LocalizedStringKey = "Tap Done below to start using this App"
    public var allSetTitle: LocalizedStringKey = "All Set!"
    
    public func makeLocalizedTitle(for type: PermissionType) -> LocalizedStringKey {
        return switch type {
            case .camera:
                "Camera"
            case .microphone:
                "Microphone"
            case .locationWhenInUse:
                "Location while in Use"
            case .locationAlways:
                "Location at all Times"
            case .notifications:
                "Notifications"
            case .photoLibrary:
                "Photo Library"
            case .contacts:
                "Contacts"
            case .bluetooth:
                "Bluetooth"
        }
    }
    public func makeLocalizedDescription(for type: PermissionType) -> LocalizedStringKey {
        return switch type {
            case .camera:
                "The \"Camera\" permission allows this app to access your camera to take photos or record videos.\n\nExample: A camera app that lets you capture photos and videos directly within the app."
            case .microphone:
                "The \"Microphone\" permission allows this app to access your microphone to record audio.\n\nExample: A voice memos app that lets you record audio notes."
            case .locationWhenInUse:
                "The \"Location While in Use\" permission allows this app to access your location only while you are actively using it.\n\nExample: A weather app that shows your current weather based on your precise location while the app is open."
            case .locationAlways:
                "The \"Location Always\" permission allows this app to access your location even when it is running in the background.\n\nExample: A navigation app that provides turn-by-turn directions even when you switch to another app."
            case .notifications:
                "The \"Notifications\" permission allows this app to send you alerts and updates.\n\nExample: A messaging app that notifies you of new messages in your chats."
            case .photoLibrary:
                "The \"Photo Library\" permission allows this app to access and modify your photos.\n\nExample: A photo viewer app that lets you browse, edit, and organize your photos."
            case .contacts:
                "The \"Contacts\" permission allows this app to access your contacts.\n\nExample: A messaging app that helps you find friends and connect with people in your contact list."
            case .bluetooth:
                "The \"Bluetooth\" permission allows this app to connect to nearby devices using Bluetooth.\n\nExample: A fitness app that syncs data with a Bluetooth heart rate monitor."
        }
    }
    public var sheetHeader: LocalizedStringKey = "This App Requires Access to"
}


import os

@MainActor
public enum PermissionType: String, CaseIterable, RawRepresentable {
    case camera, microphone, locationWhenInUse, locationAlways, notifications, photoLibrary, contacts, bluetooth
    
    /// The Localization Provider used to Localize the Permissions' Titles and Descriptions, you can set this to a Custom Provider by Changing PermissionsManager.shared.localizationProvider
    static var localizationProvider: PermissionsLocalizationProvider {
        PermissionsManager.shared.localizationProvider
    }
    
    /// A Short Title for the Permission, e.g. "Microphone"
    public var localizedTitle: LocalizedStringKey {
        return Self.localizationProvider.makeLocalizedTitle(for: self)
    }
    
    /// A Descriptive Text explaining the user what the given Permission grants your App access to
    public var localizedDescription: LocalizedStringKey {
        return Self.localizationProvider.makeLocalizedDescription(for: self)
    }
    
    public var sfSymbol: String {
        switch self {
            case .camera:
                "camera"
            case .microphone:
                "microphone"
            case .locationWhenInUse:
                "location"
            case .locationAlways:
                "location.fill"
            case .notifications:
                "app.badge"
            case .photoLibrary:
                if #available(iOS 16, *) {
                    "photo.stack"
                } else {
                    "photo"
                }
            case .contacts:
                "person.2"
            case .bluetooth:
                "dot.radiowaves.left.and.right"
        }
    }
    
    public func request() async {
        guard self.hasRequiredInfoPlistKey() else {
            return
        }
        switch self {
            case .camera:
                _ = await AVCaptureDevice.requestAccess(for: .video)
                
            case .microphone:
                _ = await AVCaptureDevice.requestAccess(for: .audio)
                
            case .locationWhenInUse:
                LocationHelper.shared.requestWhenInUse()
                
            case .notifications:
                _ = try? await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge])
                
            case .photoLibrary:
                _ = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                
            case .locationAlways:
                LocationHelper.shared.requestAlways()
                
            case .contacts:
                _ = try? await CNContactStore().requestAccess(for: .contacts)
                
            case .bluetooth:
                PermissionsManager.shared.bluetoothHelper = BluetoothHelper.shared
        }
    }
    
    public func isAuthorized() async -> Bool {
        switch self {
            case .camera:
                return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
                
            case .microphone:
                return AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
                
            case .locationWhenInUse:
                let status = CLLocationManager.authorizationStatus()
                return status == .authorizedWhenInUse || status == .authorizedAlways
                
            case .locationAlways:
                let status = CLLocationManager.authorizationStatus()
                return status == .authorizedAlways
                
            case .notifications:
                let settings = await UNUserNotificationCenter.current().notificationSettings()
                return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
                
            case .photoLibrary:
                let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                return status == .authorized || status == .limited
                
            case .contacts:
                let status = CNContactStore.authorizationStatus(for: .contacts)
                if #available(iOS 18, *) {
                    return status == .authorized || status == .limited
                } else {
                    return status == .authorized
                }
                
            case .bluetooth:
                return PermissionsManager.shared.bluetoothHelper?.isGranted == true
        }
    }
        
    

    public func hasRequiredInfoPlistKey() -> Bool {
        let bundle = Bundle.main
        
        guard let key = self.requiredPlistKey else { return true }
        let hasKey = bundle.object(forInfoDictionaryKey: key) != nil
        if !hasKey {
            let logger = Logger(subsystem: "com.timi2506.Permissions", category: "error")
            logger.critical("Required Info Plist Key Missing for \(self.rawValue): \(self.requiredPlistKey ?? "NONE")")
            print("CRITICAL: Required Info Plist Key Missing for \(self.rawValue): \(self.requiredPlistKey ?? "NONE") - This incident has been logged")
        }
        return hasKey
    }
    private var requiredPlistKey: String? {
        var requiredKey: String?
        switch self {
            case .camera:
                requiredKey = "NSCameraUsageDescription"
            case .microphone:
                requiredKey = "NSMicrophoneUsageDescription"
            case .locationWhenInUse:
                requiredKey = "NSLocationWhenInUseUsageDescription"
            case .locationAlways:
                requiredKey = "NSLocationAlwaysAndWhenInUseUsageDescription"
            case .photoLibrary:
                requiredKey = "NSPhotoLibraryUsageDescription"
            case .contacts:
                requiredKey = "NSContactsUsageDescription"
            case .bluetooth:
                requiredKey = "NSBluetoothAlwaysUsageDescription"
            case .notifications:
                requiredKey = nil
        }
        return requiredKey
    }
}

@MainActor
public class PermissionsManager: ObservableObject {
    private init() {}
    fileprivate var bluetoothHelper: BluetoothHelper?
    /// The Shared Singleton of PermissionsManager which also allows it to communicate with PermissionsSheet
    public static let shared = PermissionsManager()
    
    /// The Localization Provider used to Localize the Permissions' Titles and Descriptions, you can set this to a Custom Provider using setLocalizationProvider, or by modifying this variable, and passing in a struct that conforms to PermissionsLocalizationProvider
    public var localizationProvider: PermissionsLocalizationProvider = .defaultProvider
    /// Requests Permissions for the specified Types - Set of Permission Types
    public func requestPermissions(for types: Set<PermissionType>) async {
        for type in types {
            await type.request()
        }
    }
    /// Gets the Permission States for the specified Types with true meaning authorized and false meaning declined.
    public func getPermissionStates(for types: Set<PermissionType>) async -> [PermissionType: Bool] {
        var results: [PermissionType: Bool] = [:]
        for type in types {
            results[type] = await type.isAuthorized()
        }
        return results
    }
    
    public func setLocalizationProvider(to newProvider: PermissionsLocalizationProvider) {
        self.localizationProvider = newProvider
    }
}

public extension PermissionsManager {
    /// Requests Permissions for the specified Types - Variadic Parameters
    func requestPermissions(for types: PermissionType...) async {
        for type in types {
            await type.request()
        }
        var types: Set<PermissionType> = []
        for type in types {
            types.insert(type)
        }
        await requestPermissions(for: types)
    }
    /// Requests Permissions for the specified Type
    func requestPermissions(for type: PermissionType) async {
        await requestPermissions(for: [type])
    }
    
    /// Gets the Permission States for the specified Types with true meaning authorized and false meaning declined.
    func getPermissionStates(for types: PermissionType...) async -> [PermissionType: Bool] {
        for type in types {
            await type.request()
        }
        var types: Set<PermissionType> = []
        for type in types {
            types.insert(type)
        }
        return await getPermissionStates(for: types)
    }
    /// Requests Permissions for the specified Type
    func getPermissionState(for type: PermissionType) async -> Bool {
        return await type.isAuthorized()
    }
}

private class LocationHelper: NSObject, CLLocationManagerDelegate {
    @MainActor static let shared = LocationHelper()
    private let manager = CLLocationManager()
    
    func requestWhenInUse() {
        manager.requestWhenInUseAuthorization()
    }
    func requestAlways() {
        manager.requestAlwaysAuthorization()
    }
}

private class BluetoothHelper: NSObject, CBCentralManagerDelegate, ObservableObject {
    static let shared: BluetoothHelper = BluetoothHelper()
    
    override init() {
        super.init()
    }
    var manager: CBCentralManager?
    @Published var isGranted = false
    var onChange: (BluetoothHelper) -> Void = { _ in }
    func request() {
        if manager == nil {
            self.manager = CBCentralManager(delegate: self, queue: nil, options: [:])
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 13.0, tvOS 13, *) {
            let authorization: CBManagerAuthorization = central.authorization
            if authorization == .allowedAlways {
                isGranted = true
            } else {
                isGranted = false
            }
            onChange(self)
        }
    }
}
