//
//  HomeView.swift
//  pets
//
//  Created by Teddy Anderson on 6/7/24.
//

import SwiftUI

struct HomeView: View {
    @State private var pets: [Pet] = []
    @State private var showAddPetNameView = false
    @State private var showAlert = false
    @State private var petToDelete: Pet?
    let userId: String
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if pets.isEmpty {
                    VStack {
                        Spacer()
                        
                        Image("backgroundImage") // Use the name of the image in your assets
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: 560) // Adjust size as needed
                            .padding(.bottom, 0)
                            .padding(.top, 40)
                        
                        Spacer()
                        
                        NavigationLink(destination: EnterPetNameView(userId: userId)) {
                            Text("Add pet")
                                .font(.custom("Nunito", size: 20))
                                .foregroundColor(.darkBackground)
                                .frame(width: UIScreen.main.bounds.width * 0.9, height: 60)
                                .background(Color.actionColor)
                                .cornerRadius(50)
                                .padding(.top, -10)
                                .padding(.bottom, -10)
                        }
                        .padding()
                    }
                    .padding()
                } else {
                    VStack {
                        TabView {
                            ForEach(pets) { pet in
                                PetCardPreview(pet: pet, onDelete: {
                                    self.petToDelete = pet
                                    self.showAlert = true
                                })
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .padding(.top, 40)
                        
                        Spacer()
                    }
                    .padding()
                }
                
                VStack {
                    HStack {
                        Image("logo")
                            .resizable()
                            .frame(width: 80, height: 40) // Adjust size as needed
                            .scaledToFit()
                            .padding(.leading, 5)
                        
                        Spacer()
                        
                        if !pets.isEmpty {
                            NavigationLink(destination: EnterPetNameView(userId: userId)) {
                                Image("addpet") // Use the name of the image in your assets
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 40) // Match the size of the logo
                                    .scaledToFit()
                                    .padding(.trailing, 5)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20) // Adjust padding to align with the notch
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .onAppear(perform: fetchPets)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete Pet"),
                    message: Text("Are you sure you want to delete this pet?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let pet = petToDelete {
                            deletePet(pet)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func fetchPets() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("pets.json")

        if let data = try? Data(contentsOf: fileURL),
           let pets = try? JSONDecoder().decode([Pet].self, from: data) {
            self.pets = pets
        }
    }
    
    private func deletePet(_ pet: Pet) {
        pets.removeAll { $0.id == pet.id }
        savePets()
    }

    private func savePets() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("pets.json")

        if let encodedData = try? JSONEncoder().encode(pets) {
            try? encodedData.write(to: fileURL)
        }
    }
}

struct PetCardPreview: View {
    let pet: Pet
    let onDelete: () -> Void

    var body: some View {
        ZStack {
            // Rectangle background
            Image("cardBackground")
                .resizable()
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 560)
                .cornerRadius(16)

            // Content overlay
            VStack {
                Spacer(minLength: 20)
                
                // Yellow overlay
                Image("cardOverlay")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 460) // Adjust the height if needed
                    .padding(.top, -70) // Adjust the padding to position the overlay correctly

                // Pet image
                if let uiImage = FileManager.default.loadImage(fromPath: pet.imagePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 140, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.top, -400) // Adjust the padding to position the image correctly
                }

                // Pet name and breed
                Text(pet.name)
                    .font(.custom("Outfit", size: 36))
                    .foregroundColor(Color.actionColor)
                    .fontWeight(.black)
                    .padding(.top, -230)
                
                Text(pet.primaryBreed)
                    .font(.custom("Nunito", size: 18)) // Adjust size as needed
                    .foregroundColor(Color.descriptionText)
                    .fontWeight(.regular)
                    .padding(.top, -205)
                
                // Pet info cards
                HStack {
                    InfoCard1(iconName: "calendar", title: "\(pet.age) years", subtitle: "Age")
                    InfoCard1(iconName: "heart", title: pet.gender, subtitle: "Gender")
                    InfoCard1(iconName: "fur", title: pet.coatColor, subtitle: "Fur color")
                }
                .padding(.top, -160)
                NavigationLink(destination: CardView(pet: pet)) {
                    Text("See Details")
                        .font(.custom("Nunito", size: 18))
                        .foregroundColor(.darkBackground)
                        .frame(width: UIScreen.main.bounds.width * 0.6, height: 45)
                        .background(Color.actionColor)
                        .cornerRadius(50)
                }
                .padding(.top, -65)
                Spacer(minLength: 20)
            }
            .padding()

            // Trash icon
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDelete) {
                        Image("trash")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(16)
                            //.background(Color.black.opacity(0.6)) // Added a background to ensure touch area
                            .clipShape(Circle())
                            .offset(x: -15, y: 40) // Adjust position as needed
                    }
                    .buttonStyle(PlainButtonStyle()) // Ensure it uses the plain button style
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct EnterPetNameView: View {
    @State private var petName: String = ""
    @State private var showScanView = false
    @State private var isEditing = false
    let userId: String
    @State private var petId: String = UUID().uuidString

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Enter your pet's name")
                    .font(.custom("Outfit", size: 30))
                    .foregroundColor(.actionColor)
                    .fontWeight(.black)
                    .padding()

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(height: 44) // Adjust height as needed

                    HStack {
                        if petName.isEmpty && !isEditing {
                            Text("Pet Name")
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                                .font(.custom("Nunito", size: 18)) // Custom font for placeholder
                        }
                        TextField("", text: $petName, onEditingChanged: { editing in
                            isEditing = editing
                        })
                        .foregroundColor(.black) // Set the text color to black
                        .font(.custom("Nunito", size: 18)) // Custom font for text field
                        .padding(.horizontal)
                        .background(Color.clear)
                    }
                }
                .padding()

                Button(action: {
                    if !petName.isEmpty {
                        showScanView = true
                    }
                }) {
                    Text("Confirm")
                        .font(.custom("Nunito", size: 20))
                        .foregroundColor(.darkBackground)
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 60)
                        .background(petName.isEmpty ? Color.gray : Color.actionColor)
                        .cornerRadius(50)
                }
                .disabled(petName.isEmpty)
                .padding()
                .background(
                    NavigationLink(destination: ScanView(petName: petName, userId: userId, petId: petId), isActive: $showScanView) {
                        EmptyView()
                    }
                )
            }
        }
        .navigationBarTitle("Pet Name", displayMode: .inline)
    }
}
struct InfoCard1: View {
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
                    .offset(y: -25)
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
/*struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        EnterPetNameView()
    }
}*/


