//
//  Main.swift
//  Memex
//
//  Created by Emma Zhou on 10/11/20.
//

import SwiftUI
import CoreData
import UserNotifications

@main
struct Main: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MemexView().environment(
                \.managedObjectContext,
                Database.shared.persistentContainer.viewContext
            )
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                print("active")
            case .inactive:
                print("inactive")
            case .background:
                print("background")
                Database.shared.saveContext()
            @unknown default:
                fatalError("Unknown scene phase")
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerForPushNotifications()
        return true
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            print("Permission granted: \(granted)")
        }
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
            case "input":
                let textResponse = response as! UNTextInputNotificationResponse
                let verb = textResponse.notification.request.content.userInfo["verb"]!
                let content = textResponse.userText.lowercased()
                Memex.shared.addMessage(message: "\(verb) \(content) #polled")
            case "notification":
                let textResponse = response as! UNTextInputNotificationResponse
                let verb = textResponse.notification.request.content.userInfo["verb"]!
                let content = textResponse.userText.lowercased()
                Memex.shared.addMessage(message: "\(verb) \(content) #scheduled")
            default:
                break
        }
        completionHandler()
    }
}
