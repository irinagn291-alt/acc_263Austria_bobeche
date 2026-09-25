import SwiftUI

/// Role: Cue. One-line Line sheet from the taper menu. Not a journal.
struct WickLineSheet: View {
    @Bindable var watch: WickWatch
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: WickFace.space(2)) {
                    WickSheetBar(title: "Write Line") {
                        focused = false
                        watch.showLine = false
                    }
                    Text("One line on Reflect. Not a journal.")
                        .font(WickFace.font(.body))
                        .foregroundStyle(WickInk.Palette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    TextField("Quiet water", text: $watch.lineDraft)
                        .font(WickFace.font(.body))
                        .foregroundStyle(WickInk.Palette.ink)
                        .padding(.horizontal, WickFace.space(2))
                        .frame(maxWidth: .infinity, minHeight: WickFace.tap)
                        .wickOpaqueCard()
                        .focused($focused)
                        .submitLabel(.done)
                        .onSubmit {
                            focused = false
                            Task { await watch.writeLine() }
                        }
                        .onChange(of: watch.lineDraft) { _, next in
                            if next.contains(where: { $0.isNewline }) {
                                watch.lineDraft = next.filter { !$0.isNewline }
                            }
                        }
                    WickVerbButton(
                        title: "Save",
                        kind: .primary,
                        enabled: !watch.lineDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            && !watch.isCommitting,
                        loading: watch.isCommitting
                    ) {
                        focused = false
                        Task { await watch.writeLine() }
                    }
                    if let fault = watch.fault {
                        Text(fault)
                            .font(WickFace.font(.caption))
                            .foregroundStyle(WickInk.Palette.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(WickFace.space(2))
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollBounceBehavior(.basedOnSize)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                Rectangle().fill(WickFace.sheetGlass)
                    .ignoresSafeArea()
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = false }
                        .font(WickFace.font(.body))
                        .foregroundStyle(WickInk.Palette.accent)
                        .frame(minHeight: WickFace.tap)
                        .accessibilityLabel("Done")
                }
            }
        }
        .wickSheetRise()
        .onAppear { focused = true }
    }
}
