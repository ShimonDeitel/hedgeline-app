import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: Trim?

    @State private var draftHedgename: String = ""
    @State private var draftShapestyle: String = ""
    @State private var draftTrimnote: String = ""
    @State private var draftNotes: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.items) { item in
                            TrimRow(item: item)
                                .listRowBackground(Theme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                    loadDraft(from: item)
                                    showingAdd = true
                                }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Hedgeline")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            editingItem = nil
                            clearDraft()
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                addEditSheet
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .tint(Theme.accent)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(Theme.textSecondary)
            Text("No trims yet")
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text("Tap + to add your first entry.")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var addEditSheet: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Hedge name", text: $draftHedgename)
                        .accessibilityIdentifier("field_hedgeName")
                        .keyboardType(default)
                    TextField("Shape style", text: $draftShapestyle)
                        .accessibilityIdentifier("field_shapeStyle")
                        .keyboardType(default)
                    TextField("Trim note", text: $draftTrimnote)
                        .accessibilityIdentifier("field_trimNote")
                        .keyboardType(default)
                    TextField("Notes", text: $draftNotes)
                        .accessibilityIdentifier("field_notes")
                        .keyboardType(default)
                }
            }
            .navigationTitle(editingItem == nil ? "Add Trim" : "Edit Trim")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingAdd = false }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }

    private func loadDraft(from item: Trim) {
        draftHedgename = item.hedgeName
        draftShapestyle = item.shapeStyle
        draftTrimnote = item.trimNote
        draftNotes = item.notes
    }

    private func clearDraft() {
        draftHedgename = ""
        draftShapestyle = ""
        draftTrimnote = ""
        draftNotes = ""
    }

    private func save() {
        if let editing = editingItem {
            var updated = editing
            updated.hedgeName = draftHedgename
            updated.shapeStyle = draftShapestyle
            updated.trimNote = draftTrimnote
            updated.notes = draftNotes
            store.update(updated)
        } else {
            let item = Trim(hedgeName: draftHedgename, shapeStyle: draftShapestyle, trimNote: draftTrimnote, notes: draftNotes)
            store.add(item)
        }
        showingAdd = false
    }
}

struct TrimRow: View {
    let item: Trim

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.hedgeName.isEmpty ? "Untitled" : item.hedgeName)
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text(item.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
