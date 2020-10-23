//
//  Database.swift
//  Memex
//
//  Created by Emma Zhou on 10/18/20.
//

import Foundation
import CoreData
import SwiftUI

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
    
    @FetchRequest(
        entity: MessageType.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MessageType.verb, ascending: true)
        ]
    ) var messageTypes: FetchedResults<MessageType>
    
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
}
