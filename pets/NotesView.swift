//
//  NotesView.swift
//  pets
//
//  Created by Teddy Anderson on 6/17/24.
//

/*import SwiftUI

struct NotesView: View {
    @State private var notes: [Note] = [
        // Sample notes for demonstration
        Note(title: "Title name lorem ipsum dolor sit amet", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."),
        // Add more sample notes as needed
    ]
    @State private var isEditing = false
    @State private var newNote = Note()
    @State private var currentNote: Note?
    @State private var showAlert = false
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Notes")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()

                    Spacer()

                    Button(action: {
                        newNote = Note(title: "Title", content: "Body")
                        notes.append(newNote)
                        currentNote = newNote
                        isEditing = true
                        selectedTab = notes.count - 1 // Set the tab to the new note
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                            .padding()
                            .background(Circle().fill(Color.yellow))
                    }
                    .padding()
                }
                
                TabView(selection: $selectedTab) {
                    ForEach(notes.indices, id: \.self) { index in
                        NoteCard(note: $notes[index], isEditing: $isEditing, currentNote: $currentNote, showAlert: $showAlert, saveNote: saveNote, cancelEdit: cancelEdit)
                            .tag(index) // Tag each tab with its index
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Delete Note"), message: Text("Are you sure you want to delete this note?"), primaryButton: .destructive(Text("Delete")) {
                if let index = notes.firstIndex(where: { $0.id == currentNote?.id }) {
                    notes.remove(at: index)
                }
            }, secondaryButton: .cancel())
        }
    }

    private func saveNote() {
        if let index = notes.firstIndex(where: { $0.id == currentNote?.id }) {
            notes[index] = notes[index]
        }
        currentNote = nil
        isEditing = false
        newNote = Note() // Reset newNote after saving
    }

    private func cancelEdit() {
        if let index = notes.firstIndex(where: { $0.id == currentNote?.id }) {
            if !isEditingNewNote() {
                // Revert any changes by resetting the current note to its original value
                notes[index] = currentNote!
            } else {
                // Remove the new note if it's in edit mode and changes are canceled
                notes.remove(at: index)
            }
        }
        currentNote = nil
        isEditing = false
    }

    private func isEditingNewNote() -> Bool {
        return currentNote?.id == newNote.id
    }
}

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    
    init(title: String = "", content: String = "") {
        self.id = UUID()
        self.title = title
        self.content = content
    }
}

struct NoteCard: View {
    @Binding var note: Note
    @Binding var isEditing: Bool
    @Binding var currentNote: Note?
    @Binding var showAlert: Bool
    var saveNote: (() -> Void)? = nil
    var cancelEdit: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isEditing && currentNote?.id == note.id {
                TextField("Title", text: $note.title)
                    .foregroundColor(.yellow)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .background(Color.clear)

                TextEditor(text: $note.content)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                Spacer()

                ZStack {
                    Image("Rectangle 2891")
                        .resizable()
                        .frame(height: 80)

                    HStack {
                        if !isEditingNewNote() {
                            Button(action: {
                                currentNote = note
                                showAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .padding(.leading, 16)
                        } else {
                            Spacer()
                        }

                        Spacer()

                        Button(action: {
                            cancelEdit?()
                        }) {
                            Text("Cancel")
                                .frame(width: 100)
                                .foregroundColor(.blue)
                                .padding()
                        }
                        
                        Button(action: {
                            saveNote?()
                        }) {
                            Text("Save")
                                .frame(width: 100)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.yellow)
                                .cornerRadius(30)
                        }
                        .padding(.trailing, 16)
                    }
                }
                .offset(y: 18)
                .padding(.bottom, 16)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(note.title)
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    Text(note.content)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                ZStack {
                    Image("Rectangle 2891")
                        .resizable()
                        .frame(height: 80)
                    
                    HStack {
                        Button(action: {
                            currentNote = note
                            showAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                        
                        Button(action: {
                            isEditing = true
                            currentNote = note
                        }) {
                            Text("Edit note")
                                .frame(width: 100)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.yellow)
                                .cornerRadius(30)
                        }
                        .padding(.trailing, 16)
                    }
                }
                .offset(y: 18)
                .padding(.bottom, 16)
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.65)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(16)
        .padding([.leading, .trailing, .top])
        .padding(.top, -100)
    }

    private func isEditingNewNote() -> Bool {
        return currentNote?.id == note.id && note.title == "Title" && note.content == "Body"
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView()
    }
}
*/
