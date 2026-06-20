import SwiftUI
import SharedUI

/// Hosts the dialogue-tree builder. Phase 1 placeholder defers the 2-D
/// graph editor to a follow-on PR; rendering a coherent surface today
/// lets the app build + boot end-to-end against the SPM scaffold.
struct WriteTabView: View {
    var body: some View {
        NavigationStack {
            DialogueTreeBuilderPlaceholder()
                .navigationTitle("Write")
        }
    }
}

#Preview {
    WriteTabView()
}
