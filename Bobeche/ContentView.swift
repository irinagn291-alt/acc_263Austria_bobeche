import SwiftUI

struct ContentView: View {
    @Bindable var watch: WickWatch
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        WickChrome(watch: watch)
            .preferredColorScheme(.dark)
            .task {
                await watch.appear()
            }
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .active:
                    guard watch.didLoad else { return }
                    Task { await watch.restFromDisk() }
                case .inactive, .background:
                    Task { await watch.flush() }
                default:
                    break
                }
            }
    }
}

#Preview("Seeded") {
    ContentView(watch: WickWatch.previewSeeded())
}

#Preview("Empty") {
    ContentView(watch: WickWatch.previewEmpty())
}
