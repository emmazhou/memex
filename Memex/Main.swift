//
//  Main.swift
//  Memex
//
//  Created by Emma Zhou on 10/11/20.
//

import SwiftUI
import CoreData

@main
struct Main: App {
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
