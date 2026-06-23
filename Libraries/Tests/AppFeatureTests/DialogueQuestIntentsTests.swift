import Foundation
import Testing
@testable import AppFeature

@Suite("DialogueQuestIntents — destination + notification bridge") @MainActor
struct DialogueQuestIntentsTests {

    @Test("Every destination round-trips through Notification userInfo")
    func destinationRoundTrip() {
        for destination in DialogueQuestDestination.allCases {
            let note = Notification(
                name: DialogueQuestIntentNavigation.notificationName,
                object: nil,
                userInfo: [DialogueQuestIntentNavigation.destinationKey: destination.rawValue]
            )
            let decoded = DialogueQuestIntentNavigation.destination(from: note)
            #expect(decoded == destination)
        }
    }

    @Test("Notification with missing userInfo returns nil")
    func notificationWithoutPayloadReturnsNil() {
        let note = Notification(
            name: DialogueQuestIntentNavigation.notificationName,
            object: nil,
            userInfo: nil
        )
        #expect(DialogueQuestIntentNavigation.destination(from: note) == nil)
    }

    @Test("Notification with malformed payload returns nil")
    func notificationWithBadPayloadReturnsNil() {
        let note = Notification(
            name: DialogueQuestIntentNavigation.notificationName,
            object: nil,
            userInfo: [DialogueQuestIntentNavigation.destinationKey: "not-a-real-destination"]
        )
        #expect(DialogueQuestIntentNavigation.destination(from: note) == nil)
    }

    @Test("Every destination maps to a distinct AppTab")
    func destinationToTabMapping() {
        #expect(DialogueQuestDestination.write.tab == .write)
        #expect(DialogueQuestDestination.adventure.tab == .adventure)
        #expect(DialogueQuestDestination.progress.tab == .progress)
    }

    @Test("post emits a notification observable by the same async sequence")
    func postEmitsNotification() async throws {
        // Observe the notification stream concurrently, then post. The
        // task completes after one notification arrives.
        let observer = Task<DialogueQuestDestination?, Never> {
            for await note in NotificationCenter.default.notifications(
                named: DialogueQuestIntentNavigation.notificationName
            ) {
                if let dest = DialogueQuestIntentNavigation.destination(from: note) {
                    return dest
                }
            }
            return nil
        }
        // Tiny yield so the observer task has a chance to subscribe before
        // we post — otherwise the notification can fire before the
        // async-for-await loop is ready.
        try await Task.sleep(for: .milliseconds(50))
        DialogueQuestIntentNavigation.post(.progress)
        let received = await observer.value
        observer.cancel()
        #expect(received == .progress)
    }

    @Test("Phrase builder emits canonical phrases keyed to the app name")
    func phraseBuilderHasAppName() {
        let open = dialogueQuestPhrases.openPhrase()
        let progress = dialogueQuestPhrases.showProgress()
        let session = dialogueQuestPhrases.startSession()
        #expect(open == "Open DialogueQuest")
        #expect(progress == "Show my progress in DialogueQuest")
        #expect(session == "Start a session in DialogueQuest")
    }

    @Test("App name constant matches portfolio convention")
    func appNameMatchesPortfolio() {
        #expect(dialogueQuestAppName == "DialogueQuest")
    }

    @Test("Every intent's destination maps onto a valid AppTab")
    func intentsHaveValidDestinations() {
        if #available(iOS 26.0, macOS 26.0, *) {
            #expect(OpenDialogueQuestIntent().destination == .write)
            #expect(StartDialogueIntent().destination == .write)
            #expect(ShowMyProgressIntent().destination == .progress)
            #expect(OpenWordWorkshopIntent().destination == .adventure)
        }
    }

    @Test("OpenAppWhenRun is true for every intent (deep-link semantics)")
    func intentsOpenApp() {
        if #available(iOS 26.0, macOS 26.0, *) {
            #expect(OpenDialogueQuestIntent.openAppWhenRun)
            #expect(StartDialogueIntent.openAppWhenRun)
            #expect(ShowMyProgressIntent.openAppWhenRun)
            #expect(OpenWordWorkshopIntent.openAppWhenRun)
        }
    }
}
