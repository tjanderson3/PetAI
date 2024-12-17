//
//  CardView.swift
//  pets
//
//  Created by Teddy Anderson on 6/6/24.
//

import SwiftUI

struct CardView: View {
    @State private var isExpanded = false // State variable to track expanded state
    @State private var galleryImages: [GalleryImage] = []
    @State private var notes: [Note] = []
    @State private var showingImagePicker = false
    @State private var showingAddNoteView = false
    @State private var inputImage: UIImage?
    @State private var noteToEdit: Note? = nil // State to track the note being edited
    
    
    var pet: Pet
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Set the entire background to black
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    NavigationLink(destination: HomeView(userId: pet.userId).navigationBarHidden(true)) {
                        Image(systemName: "house.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    Text("Pet Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    // Placeholder to balance the title
                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.clear)
                        .padding()
                }
                //.padding()
                .background(Color.black)
                ScrollView {
                    LazyVStack(spacing: 16) { // Increased spacing between sections
                        // Pet header
                        VStack(spacing: 16) {
                            HStack(alignment: .top) {
                                if let uiImage = FileManager.default.loadImage(fromPath: pet.imagePath) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .padding(.leading, 0)
                                        .frame(width: 140, height: 160) // Increased size
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } else {
                                    Image("dogprev") // Placeholder for the pet image
                                        .resizable()
                                        .padding(.leading, 0)
                                        .frame(width: 140, height: 160) // Increased size
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    //.padding(.trailing, 20)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("\(pet.name)")
                                            .modifier(OnboardingTitles()) // Applied custom modifier
                                            .padding(.trailing, -40)
                                        Spacer()
                                        
                                        Button(action: {
                                            withAnimation {
                                                isExpanded.toggle()
                                            }
                                        }) {
                                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                                .foregroundColor(.yellow)
                                                .padding()
                                                .offset(x: 20)
                                        }
                                    }
                                    
                                    Text(pet.primaryBreed)
                                        .modifier(OnboardingInfo())
                                        .padding(.bottom, 10) // Applied custom modifier
                                    
                                    HStack(spacing: 8) { // Decreased spacing between info cards
                                        InfoCard2(iconName: "calendar", title: "\(Int(pet.age)) years", subtitle: "Age")
                                        InfoCard2(iconName: "fur", title: pet.coatColor, subtitle: "Fur color")
                                            .padding(.trailing, 8)
                                    }
                                }
                                Spacer()
                            }
                            if isExpanded {
                                VStack(spacing: 8) { // Reduced spacing between info cards
                                    HStack(spacing: 8) {
                                        InfoCard2(iconName: "scale", title: "\(Int(pet.weight)) lbs", subtitle: "Weight")
                                        InfoCard2(iconName: "height", title: "\(Int(pet.height)) in", subtitle: "Height")
                                        InfoCard2(iconName: "length", title: "\(Int(pet.length)) in", subtitle: "Length")
                                        InfoCard2(iconName: "petting", title: pet.personality ?? "Unknown", subtitle: "Personality")
                                            .padding(.trailing, 8)
                                    }
                                    HStack(spacing: 8) {
                                        InfoCard2(iconName: "height", title: pet.coatLength, subtitle: "Coat Length")
                                        InfoCard2(iconName: "comb", title: pet.coatType, subtitle: "Coat Type")
                                        InfoCard2(iconName: "dog", title: pet.fitnessLevel, subtitle: "Fitness Level")
                                        InfoCard2(iconName: "heart", title: pet.gender, subtitle: "Gender")
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                        }
                        .padding()
                        .padding(.bottom, 14)
                        .shadow(radius: 5)
                        .background(Color.darkBackground)
                        .cornerRadius(16) // Rounded corners for the header section
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        
                        // Chat with Expert, Imagine your Pet, and Tips for your Pet buttons
                        VStack(spacing: 16) {
                            NavigationLink(destination: ChatView(userId: pet.userId, petId: pet.petId)) {
                                Text("Chat with Expert")
                                    .font(.custom("Nunito", size: 20))
                                    .bold()
                                    .foregroundColor(.darkBackground)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.actionColor)
                                    .cornerRadius(8)
                            }
                            
                            HStack(spacing: 16) {
                                NavigationLink(destination: UploadPhotosView()) {
                                    Text("Imagine your Pet")
                                        .bold()
                                        .font(.custom("Nunito", size: 20))
                                        .foregroundColor(.darkBackground)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.actionColor)
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    // Tips for your Pet action
                                }) {
                                    NavigationLink(destination: PetTipsView(petId: pet.petId, userId: pet.userId)) {
                                        Text("Tips for your Pet")
                                            .bold()
                                            .font(.custom("Nunito", size: 20))
                                            .foregroundColor(.darkBackground)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.actionColor)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding([.leading, .trailing])
                        .padding(.bottom)
                        
                        // Notes and Gallery
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Gallery")
                                    .modifier(OnboardingTitles()) // Applied custom modifier
                                
                                Spacer() // Push the plus icon to the right
                                
                                Button(action: {
                                    showingImagePicker = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.yellow)
                                            .frame(width: 30, height: 30)
                                        
                                        Image(systemName: "plus")
                                            .foregroundColor(.black)
                                            .bold()
                                    }
                                }
                                
                                if galleryImages.isEmpty {
                                    Text("See All")
                                        .foregroundColor(.gray)
                                        .padding(.trailing)
                                } else {
                                    NavigationLink(destination: GalleryDetailView(galleryImages: galleryImages, petId: pet.petId, petName: pet.name)) {
                                        Text("See All")
                                            .foregroundColor(.yellow)
                                            .padding(.trailing)
                                    }
                                }
                            }
                            .padding(.bottom, 8)
                            
                            // Gallery images
                            GeometryReader { geometry in
                                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                                    ForEach(galleryImages.prefix(6)) { galleryImage in
                                        if let uiImage = UIImage(contentsOfFile: galleryImage.imagePath) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: (geometry.size.width - 32) / 3, height: (geometry.size.width - 32) / 3)
                                                .clipped()
                                                .cornerRadius(8)
                                        }
                                    }
                                    if galleryImages.count < 6 {
                                        ForEach(galleryImages.count..<6, id: \.self) { _ in
                                            Rectangle()
                                                .strokeBorder(Color.darkBackground, lineWidth: 2)
                                                .background(Color.black)
                                                .cornerRadius(8)
                                                .frame(width: (geometry.size.width - 32) / 3, height: (geometry.size.width - 32) / 3)
                                        }
                                    }
                                }
                            }
                            .frame(height: 240) // Adjust height based on the number of items
                        }
                        .padding([.leading, .trailing, .bottom])
                        .onAppear {
                            galleryImages = FileManager.default.loadGalleryImages(forPetId: pet.petId)
                        }
                        
                        // Notes Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Notes")
                                    .modifier(OnboardingTitles())
                                    .padding(.leading)
                                
                                Spacer()
                                
                                Button(action: {
                                    noteToEdit = nil
                                    showingAddNoteView = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.yellow)
                                            .frame(width: 30, height: 30)
                                        
                                        Image(systemName: "plus")
                                            .foregroundColor(.black)
                                            .bold()
                                    }
                                }
                                
                                if notes.isEmpty {
                                    Text("See All")
                                        .foregroundColor(.gray)
                                        .padding(.trailing)
                                } else {
                                    NavigationLink(destination: NotesListView(notes: notes, petId: pet.petId, userId: pet.userId)) {
                                        Text("See All")
                                            .foregroundColor(.yellow)
                                            .padding(.trailing)
                                    }
                                }
                            }
                            .padding(.bottom, 8)
                            
                            VStack(spacing: 8) {
                                if notes.isEmpty {
                                    HStack {
                                        Image(systemName: "note.text")
                                            .foregroundColor(.white)
                                        VStack(alignment: .leading) {
                                            Text("No notes yet")
                                                .foregroundColor(.yellow)
                                                .font(.custom("Nunito", size: 16))
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.darkBackground)
                                    .cornerRadius(8)
                                } else {
                                    ForEach(notes.sorted(by: { $0.date > $1.date }).prefix(3)) { note in
                                        HStack {
                                            Image(systemName: "note.text")
                                                .foregroundColor(.white)
                                            VStack(alignment: .leading) {
                                                Text(note.title)
                                                    .foregroundColor(.yellow)
                                                    .font(.custom("Nunito", size: 16))
                                                Text(note.date, style: .date)
                                                    .foregroundColor(.gray)
                                                    .font(.custom("Nunito", size: 14))
                                            }
                                            Spacer()
                                            Button(action: {
                                                noteToEdit = note
                                                showingAddNoteView = true
                                            }) {
                                                Image(systemName: "pencil.circle.fill")
                                                    .foregroundColor(.yellow)
                                            }
                                        }
                                        .padding()
                                        .background(Color.darkBackground)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding([.leading, .trailing])
                        }
                        .padding(.bottom, 20)
                        .onAppear {
                            loadNotes()
                        }
                        
                        // Share Button
                        Button(action: {
                            // Share action
                        }) {
                            Text("Share my pet")
                                .font(.custom("Nunito", size: 20))
                                .bold()
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.actionColor)
                                .cornerRadius(8)
                        }
                        .padding([.leading, .trailing, .bottom])
                    }
                    .background(Color.black)
                }
            }
            .fullScreenCover(isPresented: $showingImagePicker, onDismiss: addImage) {
                ImagePicker(image: $inputImage, sourceType: .photoLibrary)
                    .edgesIgnoringSafeArea(.all)
            }
            .sheet(isPresented: $showingAddNoteView, onDismiss: loadNotes) {
                AddNoteView(notes: $notes, petId: pet.petId, userId: pet.userId, existingNote: noteToEdit)
            }
            .navigationBarHidden(true)
        }
    }
    
    private func addImage() {
        guard let inputImage = inputImage else { return }
        if let imagePath = FileManager.default.saveGalleryImage(image: inputImage, withName: UUID().uuidString, forPetId: pet.petId) {
            galleryImages.append(GalleryImage(imagePath: imagePath))
        }
    }
    
    private func loadNotes() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("\(pet.userId)_\(pet.petId)_notes.json")
        if let data = try? Data(contentsOf: fileURL),
           let loadedNotes = try? JSONDecoder().decode([Note].self, from: data) {
            notes = loadedNotes
        }
    }
}

/*struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePet = Pet(
            id: UUID(),
            name: "Miss",
            primaryBreed: "Golden Retriever",
            secondaryBreed: "None",
            height: 60.0,
            weight: 30.0,
            length: 80.0,
            gender: "Male",
            coatLength: "Medium",
            coatType: "Curly",
            coatColor: "Golden",
            age: 3,
            fitnessLevel: "Active",
            animalType: "Dog",
            imagePath: ""
        )
        CardView(pet: samplePet)
    }
}*/
struct InfoCard2: View {
    let iconName: String
    let title: String
    let subtitle: String
    
    var body: some View {
        ZStack {
            // Rectangle background
            Image("block")
                .resizable()
                .frame(width: 75, height: 72) // Adjust size as needed
                .cornerRadius(8)

            VStack(spacing: 2) {
                // Custom icon
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
                    .foregroundColor(.white)
                    .offset(y: -18)
                Text(title)
                    .font(.custom("Outfit", size: 14))
                    .foregroundColor(Color.actionColor)
                    .fontWeight(.black)
                    .padding(.top, -15)
                Text(subtitle)
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(.white)
            }
        }
    }
}

