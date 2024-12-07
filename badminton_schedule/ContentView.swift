//
//  ContentView.swift
//  badminton_schedule
//
//  Created by rge geo on 2024/12/7.
//

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
    @State private var showResetConfirmation: Bool = false // Tracks reset confirmation dialog

    private let storageKey = "NameBlocksStorage"

    var body: some View {
        NavigationView {
            VStack {
                // Grid layout for blocks
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach($nameBlocks) { $block in
                            // Block View
                            VStack {
                                Text(block.name)
                                    .font(.headline)
                                Text("\(block.count)")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity, minHeight: 70)
                            .background(selectedBlocks.contains(block.id) ? Color.yellow.opacity(0.4) : Color.blue.opacity(0.2))
                            .cornerRadius(8)
                            .padding()
                            .onTapGesture {
                                // Toggle block selection
                                if selectedBlocks.contains(block.id) {
                                    selectedBlocks.remove(block.id)
                                } else {
                                    selectedBlocks.insert(block.id)
                                }
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
                }
                // Reset Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showResetConfirmation = true // Show reset confirmation dialog
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            // Input dialog for adding a name
            .alert("Add Name", isPresented: $showInputDialog) {
                TextField("Enter a name", text: $newName)
                Button("Add") {
                    if !newName.isEmpty {
                        // Add a new block with name and default count of 0
                        let newBlock = NameBlock(id: UUID(), name: newName, count: 0)
                        nameBlocks.append(newBlock)
                        saveData() // Save data after adding
                        newName = "" // Clear input after adding
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            // Reset confirmation dialog
            .alert("Reset All Name Blocks?", isPresented: $showResetConfirmation) {
                Button("Reset", role: .destructive) {
                    nameBlocks.removeAll() // Clear all name blocks
                    saveData() // Save the empty state
                }
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
