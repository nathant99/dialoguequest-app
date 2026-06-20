import SwiftUI
import SharedUI

/// Word Workshop adventure tab. The `DialogueQuestHubContribution`
/// Level-2 overlay ships in this target and is wired into AdventureHub
/// from the cross-app shell (see `Docs/HANDOFF_TO_HUB_HUBCONTRIBUTION_LEVEL_1.md`).
///
/// Within DialogueQuest, the Adventure tab is a quiet status surface
/// until hub-side Level-1 JSON lands. Kids playing DialogueQuest alone
/// see a friendly note + nudge back to the Write tab.
struct AdventureTabView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: "tree")
                    .font(.system(size: 64))
                    .foregroundStyle(DialoguePalette.rust)
                    .frame(maxWidth: .infinity)

                Text("Word Workshop")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("DialogueQuest's contribution to AdventureHub. The Word Workshop zone unlocks once the cross-app hub ships its Level-1 zone tile.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                MentorBubbleView(
                    message: "While the Workshop is being built, keep writing in the Write tab. The Anthology tracks every published tree."
                )

                Spacer()
            }
            .padding()
            .navigationTitle("Adventure")
            .background(DialoguePalette.cream.opacity(0.6))
        }
    }
}

#Preview {
    AdventureTabView()
}
