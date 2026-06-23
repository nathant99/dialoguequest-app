import Foundation
import Testing
@testable import Models
@testable import Services

@Suite("DialogueAudioExporter")
struct DialogueAudioExporterTests {

    @Test func sanitizedFilenamePreservesAllowedCharacters() {
        let sanitized = DialogueAudioExporter.sanitizedFilename(
            "After the rain",
            fallback: "dialogue"
        )
        #expect(sanitized == "After the rain")
    }

    @Test func sanitizedFilenameCollapsesDisallowedCharacters() {
        let sanitized = DialogueAudioExporter.sanitizedFilename(
            "Iris/Cal — \"the cliff\"",
            fallback: "dialogue"
        )
        // Non-alnum / non-dash / non-underscore / non-space → underscore.
        #expect(sanitized.contains("Iris_Cal"))
        #expect(!sanitized.contains("/"))
        #expect(!sanitized.contains("\""))
    }

    @Test func sanitizedFilenameFallsBackOnPunctuation() {
        let sanitized = DialogueAudioExporter.sanitizedFilename("...", fallback: "dialogue")
        #expect(sanitized == "dialogue")
    }

    @Test func sanitizedFilenameClampsTo60Chars() {
        let long = String(repeating: "a", count: 120)
        let sanitized = DialogueAudioExporter.sanitizedFilename(long, fallback: "dialogue")
        #expect(sanitized.count <= 60)
    }

    @Test func renderJobsAreSendableAndDepthFirst() {
        let character = DialogueCharacterRef(
            id: UUID(),
            name: "Iris",
            voiceRegister: "fast and bright",
            sampleLines: ["Hi!"]
        )
        let root = DialogueNode(
            id: UUID(),
            speakerID: character.id,
            surfaceText: "Hello.",
            inferredSubtext: nil,
            tag: .said("Iris"),
            children: [],
            createdAt: .now
        )
        let tree = DialogueTree(
            title: "Single",
            characters: [character],
            nodes: [root],
            rootNodeID: root.id
        )
        let jobs = DialogueAudioExporter.renderJobs(for: tree)
        #expect(jobs.count == 1)
        #expect(jobs.first?.text == "Hello.")
        #expect(jobs.first?.voiceIdentifier != nil)
    }

    @Test func renderJobsEmptyForEmptyTree() {
        let tree = DialogueTree(
            title: "Empty",
            characters: [],
            nodes: [],
            rootNodeID: UUID()
        )
        #expect(DialogueAudioExporter.renderJobs(for: tree).isEmpty)
    }

    @Test func renderJobPropagatesVoiceRegisterNudge() {
        let character = DialogueCharacterRef(
            id: UUID(),
            name: "Rest",
            voiceRegister: "soft and hushed",
            sampleLines: ["Listen."]
        )
        let node = DialogueNode(
            id: UUID(),
            speakerID: character.id,
            surfaceText: "Listen.",
            inferredSubtext: nil,
            tag: .said("Rest"),
            children: [],
            createdAt: .now
        )
        let tree = DialogueTree(
            title: "Hushed",
            characters: [character],
            nodes: [node],
            rootNodeID: node.id
        )
        let jobs = DialogueAudioExporter.renderJobs(for: tree)
        let baseline = DialogueReadAloudService.PaceNudge.default
        #expect(jobs.first?.postUtteranceDelay ?? 0 > baseline.postDelay)
    }
}
