//
//  Database.swift
//  Memex
//
//  Created by Emma Zhou on 10/18/20.
//

import Foundation
import CoreData
import SwiftUI
import UserNotifications

class Database: ObservableObject {
    static let shared = Database()
        
    var context: NSManagedObjectContext { persistentContainer.viewContext }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Memex")
        guard let descriptions = container.persistentStoreDescriptions.first else {
            fatalError("\(#function): Failed to retrieve a persistent store description.")
        }
        descriptions.setOption(true as NSNumber,
                               forKey: NSPersistentHistoryTrackingKey)
        descriptions.setOption(true as NSNumber,
                               forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Unresolved error \(error)")
            }
        }
    }
    
    func addMessageType(verb: String) {
        let context = persistentContainer.viewContext
        let newType = MessageType(context: context)
        newType.verb = verb
        saveContext()
    }
    
    func deleteMessageType(messageType: MessageType) {
        let context = persistentContainer.viewContext
        context.delete(messageType)
        saveContext()
    }
    
    func addIntervalNotification(verb: String, interval: TimeInterval) {
        let context = persistentContainer.viewContext
        let newNotification = IntervalNotification(context: context)
        newNotification.uuid = UUID().uuidString
        newNotification.verb = verb
        newNotification.interval = interval
        saveContext()
    }
    
    func updateIntervalNotification(notification: IntervalNotification, interval: TimeInterval) {
        notification.setValue(interval, forKey: "interval")
        saveContext()
    }
    
    func startIntervalNotification(notification: IntervalNotification) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = notification.verb!
        content.categoryIdentifier = "alarm"
        content.userInfo = ["verb": notification.verb]
        content.sound = UNNotificationSound.default
        
        let inputAction = UNTextInputNotificationAction(
            identifier: "input", title: "Input", options: [])
        let category = UNNotificationCategory(
            identifier: "actionCategory", actions: [inputAction], intentIdentifiers: [], options: [])
        content.categoryIdentifier = "actionCategory"
        UNUserNotificationCenter.current().setNotificationCategories([category])

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: notification.interval, repeats: true)
        let request = UNNotificationRequest(
            identifier: notification.uuid!, content: content, trigger: trigger)
        center.add(request)

        notification.setValue(true, forKey: "active")
        saveContext()
    }
    
    func stopIntervalNotification(notification: IntervalNotification) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notification.uuid!])
        
        notification.setValue(false, forKey: "active")
        saveContext()
    }
    
    func deleteIntervalNotification(notification: IntervalNotification) {
        stopIntervalNotification(notification: notification)

        let context = persistentContainer.viewContext
        context.delete(notification)
        saveContext()
    }
    
    func addCalendarNotification(verb: String, hour: Int16, minute: Int16) {
        let context = persistentContainer.viewContext
        let newNotification = CalendarNotification(context: context)
        newNotification.uuid = UUID().uuidString
        newNotification.verb = verb
        newNotification.hour = hour
        newNotification.minute = minute
        saveContext()
    }
    
    func updateCalendarNotification(notification: CalendarNotification, time: Date) {
        var calendar = Calendar.current
        calendar.timeZone = .current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        notification.setValue(components.hour, forKey: "hour")
        notification.setValue(components.minute, forKey: "minute")
        saveContext()
    }
    
    func startCalendarNotification(notification: CalendarNotification) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = notification.verb!
        content.categoryIdentifier = "alarm"
        content.userInfo = ["verb": notification.verb]
        content.sound = UNNotificationSound.default
        
        let inputAction = UNTextInputNotificationAction(
            identifier: "notification", title: "Notification", options: [])
        let category = UNNotificationCategory(
            identifier: "actionCategory", actions: [inputAction], intentIdentifiers: [], options: [])
        content.categoryIdentifier = "actionCategory"
        UNUserNotificationCenter.current().setNotificationCategories([category])

        var date = DateComponents()
        date.hour = Int(notification.hour)
        date.minute = Int(notification.minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(
            identifier: notification.uuid!, content: content, trigger: trigger)
        center.add(request)

        notification.setValue(true, forKey: "active")
        saveContext()
    }

    
    func stopCalendarNotification(notification: CalendarNotification) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notification.uuid!])
        
        notification.setValue(false, forKey: "active")
        saveContext()
    }
    
    func deleteCalendarNotification(notification: CalendarNotification) {
        stopCalendarNotification(notification: notification)

        let context = persistentContainer.viewContext
        context.delete(notification)
        saveContext()
    }
}
