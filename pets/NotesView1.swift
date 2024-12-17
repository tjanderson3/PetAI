//
//  NotesView1.swift
//  pets
//
//  Created by Teddy Anderson on 7/10/24.
//

import SwiftUI
import Foundation

struct Note: Codable, Identifiable {
    let id: UUID
    var title: String
    var content: String
    let date: Date
}

struct AddNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var notes: [Note]
    let petId: String
    let userId: String
    var existingNote: Note? = nil // Optional existing note for editing

    @State private var title = ""
    @State private var content = ""

    var body: some View {
        VStack {
            TextField("Title", text: $title)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.bottom)

            TextEditor(text: $content)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.bottom)

            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    let newNote = Note(
                        id: existingNote?.id ?? UUID(),
                        title: title,
                        content: content,
                        date: existingNote?.date ?? Date()
                    )

                    if let index = notes.firstIndex(where: { $0.id == newNote.id }) {
                        notes[index] = newNote
                    } else {
                        notes.append(newNote)
                    }
                    
                    saveNotes()
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .padding()
        .onAppear {
            if let existingNote = existingNote {
                title = existingNote.title
                content = existingNote.content
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private func saveNotes() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("\(userId)_\(petId)_notes.json")
        if let data = try? JSONEncoder().encode(notes) {
            try? data.write(to: fileURL)
        }
    }
}

struct NotesListView: View {
    @State var notes: [Note]
    let petId: String
    let userId: String

    var body: some View {
        List {
            ForEach(notes) { note in
                NavigationLink(destination: NoteDetailView(note: note, onSave: { updatedNote in
                    if let index = notes.firstIndex(where: { $0.id == note.id }) {
                        notes[index] = updatedNote
                        saveNotes()
                    }
                })) {
                    VStack(alignment: .leading) {
                        Text(note.title)
                            .font(.headline)
                            .foregroundColor(.yellow)
                        Text(note.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(note.content)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                    .padding()
                    .background(Color.darkBackground)
                    .cornerRadius(8)
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationTitle("Notes")
        .onAppear {
            notes.sort { $0.date > $1.date } // Sort notes by most recent date
        }
        
    }
    private func saveNotes() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("\(userId)_\(petId)_notes.json")
        if let data = try? JSONEncoder().encode(notes) {
            try? data.write(to: fileURL)
        }
    }
}

struct NoteDetailView: View {
    @State private var title: String
    @State private var content: String
    var note: Note
    var onSave: (Note) -> Void

    @Environment(\.presentationMode) var presentationMode

    init(note: Note, onSave: @escaping (Note) -> Void) {
        self.note = note
        self.onSave = onSave
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
    }

    var body: some View {
        VStack {
            TextField("Title", text: $title)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.bottom)

            TextEditor(text: $content)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.bottom)

            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    var updatedNote = note
                    updatedNote.title = title
                    updatedNote.content = content
                    onSave(updatedNote)
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .padding()
        .navigationTitle("Edit Note")
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .scrollContentBackground(.hidden)
    }
}
