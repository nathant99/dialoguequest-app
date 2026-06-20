//
//  DialogueQuestApp.swift
//  DialogueQuest
//
//  Created by Nghi Tran on 6/19/26.
//

import SwiftUI
import SwiftData
import AppFeature
import Models

@main
struct DialogueQuestApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: PersistentDialogueTree.self,
                migrationPlan: DialogueQuestMigrationPlan.self
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
