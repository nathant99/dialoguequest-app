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
import Services
#if canImport(UIKit)
import UIKit
#endif

@main
struct DialogueQuestApp: App {
    let modelContainer: ModelContainer

    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Emit a single startup line so the lifecycle trace begins with a
        // known anchor. Per `.claude/rules/debug-logging.md` § "iOS — app
        // shell", the cumulative lifecycle trace is the load-bearing
        // diagnostic surface for first-launch crashes, scene-phase races,
        // and (future) deep-link routing. `#if DEBUG`-gated at the emitter
        // so release builds compile to ().
        DialogueQuestDebugLog.startup("DialogueQuestApp.init — ModelContainer initializing")
        do {
            modelContainer = try ModelContainer(
                for: PersistentDialogueTree.self,
                AnthologyCollectionRecord.self,
                migrationPlan: DialogueQuestMigrationPlan.self
            )
            DialogueQuestDebugLog.startup("DialogueQuestApp.init — ModelContainer ready")
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL { url in
                    DialogueQuestDebugLog.lifecycle(
                        "onOpenURL — scheme=\(url.scheme ?? "<nil>") host=\(url.host ?? "<nil>")"
                    )
                }
                #if canImport(UIKit)
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIApplication.didReceiveMemoryWarningNotification
                    )
                ) { _ in
                    DialogueQuestDebugLog.lifecycle("memory warning")
                }
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIApplication.willTerminateNotification
                    )
                ) { _ in
                    DialogueQuestDebugLog.lifecycle("willTerminate")
                }
                #endif
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { old, new in
            DialogueQuestDebugLog.lifecycle("scenePhase \(old) → \(new)")
        }
    }
}
