import SwiftUI

struct ContentView: View {
    // Define a structure for name blocks with a name and a counter
    struct NameBlock: Identifiable, Codable {
        let id: UUID // Unique identifier
        var name: String
        var count: Int
    }

    // State variables
    @State private var nameBlocks: [NameBlock] = [] // List of name blocks
    @State private var newName: String = "" // Temp name from the input dialog
    @State private var showInputDialog: Bool = false // Tracks input dialog visibility
    @State private var selectedBlocks: Set<UUID> = [] // Stores the IDs of selected blocks
    @State private var blockToDelete: NameBlock? = nil // Block pending deletion
    @State private var showDeleteConfirmation: Bool = false // Tracks delete confirmation dialog
    @State private var highlightedBlockID: UUID? = nil // Tracks the block to highlight
    @State private var showClearAllConfirmation: Bool = false // Tracks clear all confirmation dialog

    private let storageKey = "NameBlocksStorage"

    var body: some View {
        NavigationView {
            VStack {
                // Grid layout for blocks
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach($nameBlocks) { $block in
                            // Block View
                            VStack {
                                Text(block.name)
                                    .font(.headline)
                                    .accessibilityIdentifier("NameBlock-\(block.id)") // Unique identifier for the name block
                                Text("\(block.count)")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.blue)
                                    .accessibilityIdentifier("CountLabel-\(block.id)") // Unique identifier for the count label
                            }
                            .frame(maxWidth: .infinity, minHeight: 70)
                            .background(
                                block.id == highlightedBlockID
                                    ? Color.red.opacity(0.4) // Highlighted color for deletion
                                    : (selectedBlocks.contains(block.id) ? Color.yellow.opacity(0.4) : Color.blue.opacity(0.2))
                            )
                            .cornerRadius(8)
                            .onTapGesture {
                                // Toggle block selection
                                if selectedBlocks.contains(block.id) {
                                    selectedBlocks.remove(block.id)
                                } else {
                                    selectedBlocks.insert(block.id)
                                }
                            }
                            .onLongPressGesture {
                                // Highlight the block and show confirmation dialog
                                highlightedBlockID = block.id
                                blockToDelete = block
                                showDeleteConfirmation = true
                            }
                        }
                    }
                }
                .padding()

                // Confirmation button at the bottom-left corner
                HStack {
                    if !selectedBlocks.isEmpty {
                        Button(action: {
                            // Confirm increment for all selected blocks
                            for blockID in selectedBlocks {
                                if let index = nameBlocks.firstIndex(where: { $0.id == blockID }) {
                                    nameBlocks[index].count += 1
                                }
                            }
                            saveData() // Save data after confirmation
                            selectedBlocks.removeAll() // Clear selections after confirmation
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Confirm Add 1")
                            }
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.leading)
                        .accessibilityIdentifier("ConfirmAddButton") // Identifier for the confirm button
                    }
                    Spacer() // Push the button to the bottom-left corner
                }
            }
            .navigationTitle("羽球小學堂")
            .toolbar {
                // Add Name Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showInputDialog = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                    .accessibilityIdentifier("AddButton") // Identifier for the add button
                }
                // Clear All Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showClearAllConfirmation = true // Show clear all confirmation dialog
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .accessibilityIdentifier("ClearAllButton") // Identifier for the clear all button
                }
            }
            // Input dialog for adding a name
            .alert("Add Name", isPresented: $showInputDialog) {
                TextField("Enter a name", text: $newName)
                    .accessibilityIdentifier("NameTextField") // Identifier for the text field
                Button("Add") {
                    if !newName.isEmpty {
                        // Add a new block with name and default count of 0
                        let newBlock = NameBlock(id: UUID(), name: newName, count: 0)
                        nameBlocks.append(newBlock)
                        saveData() // Save data after adding
                        newName = "" // Clear input after adding
                    }
                }
                .accessibilityIdentifier("AddConfirmButton") // Identifier for the confirm add button
                Button("Cancel", role: .cancel) { }
            }
            // Delete confirmation dialog
            .alert("Delete this block?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let blockToDelete = blockToDelete {
                        nameBlocks.removeAll { $0.id == blockToDelete.id } // Remove the selected block
                        saveData() // Save the updated data
                        highlightedBlockID = nil // Clear the highlight after deletion
                    }
                }
                .accessibilityIdentifier("DeleteConfirmButton") // Identifier for delete confirmation
                Button("Cancel", role: .cancel) {
                    highlightedBlockID = nil // Clear the highlight if canceled
                }
            }
            // Clear all confirmation dialog
            .alert("Clear all name blocks?", isPresented: $showClearAllConfirmation) {
                Button("Clear All", role: .destructive) {
                    nameBlocks.removeAll() // Clear all name blocks
                    saveData() // Save the empty state
                }
                .accessibilityIdentifier("ClearAllConfirmButton") // Identifier for clear all confirmation
                Button("Cancel", role: .cancel) { }
            }
            .onAppear {
                loadData() // Load data when the app starts
            }
        }
    }

    // Save data to UserDefaults
    private func saveData() {
        do {
            let data = try JSONEncoder().encode(nameBlocks)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Error saving data: \(error)")
        }
    }

    // Load data from UserDefaults
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do {
                nameBlocks = try JSONDecoder().decode([NameBlock].self, from: data)
            } catch {
                print("Error loading data: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
