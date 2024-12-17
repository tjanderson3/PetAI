//
//  ConfirmPetInfoView.swift
//  pets
//
//  Created by Teddy Anderson on 6/9/24.
//

import SwiftUI

struct ConfirmPetInfoView: View {
    @State private var primaryBreed: String
    @State private var secondaryBreed: String
    @State private var height: Double
    @State private var weight: Double
    @State private var length: Double
    @State private var gender: String
    @State private var coatLength: String
    @State private var coatType: String
    @State private var coatColor: String
    @State private var fitnessLevel: String
    @State private var animalType: String
    
    @State private var showingEditScreen: Bool = false
    @State private var editTitle: String = ""
    @State private var editValue: String = ""
    @State private var isNumberField: Bool = false
    @State private var isPickerField: Bool = false
    @State private var pickerOptions: [String] = []
    
    @State private var updatedPet: Pet

    init(pet: Pet) {
        self._updatedPet = State(initialValue: pet)
        _primaryBreed = State(initialValue: pet.primaryBreed)
        _secondaryBreed = State(initialValue: pet.secondaryBreed ?? "None")
        _height = State(initialValue: pet.height)
        _weight = State(initialValue: pet.weight)
        _length = State(initialValue: pet.length)
        _gender = State(initialValue: pet.gender)
        _coatLength = State(initialValue: pet.coatLength)
        _coatType = State(initialValue: pet.coatType)
        _coatColor = State(initialValue: pet.coatColor)
        _fitnessLevel = State(initialValue: pet.fitnessLevel)
        _animalType = State(initialValue: pet.animalType)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Spacer().frame(height: 4) // Increase space between navigation title and primary breed text
                
                Text("Primary Breed")
                    .font(.custom("Nunito", size: 20))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                
                HStack {
                    Image("breed") // Use the name of your breed background image asset
                        .resizable()
                        .frame(height: 40)
                        .overlay(
                            Text(primaryBreed)
                                .font(.custom("Outfit", size: 18))
                                .foregroundColor(.actionColor)
                                .fontWeight(.bold)
                                .lineLimit(nil)
                        )
                        .onTapGesture {
                            self.showEditScreen(title: "Primary Breed", value: self.primaryBreed)
                        }
                    Spacer()
                }

                // Conditionally show the secondary breed
                if secondaryBreed != "None" {
                    Text("Secondary Breed")
                        .font(.custom("Nunito", size: 20))
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image("breed") // Use the name of your breed background image asset
                            .resizable()
                            .frame(height: 40)
                            .overlay(
                                Text(secondaryBreed)
                                    .font(.custom("Outfit", size: 18))
                                    .foregroundColor(.actionColor)
                                    .fontWeight(.bold)
                                    .lineLimit(nil)
                            )
                            .onTapGesture {
                                self.showEditScreen(title: "Secondary Breed", value: self.secondaryBreed)
                            }
                        Spacer()
                    }
                }

                Image("divider") // Use the name of your divider image asset
                    .resizable()
                    .frame(height: 2)
                    .padding(.vertical, 10) // Decrease vertical padding to reduce space between divider and detail boxes
                
                VStack(spacing: 1) {
                    HStack {
                        DetailBox(iconName: "heart", title: "Gender", value: gender) {
                            self.showEditScreen(title: "Gender", value: self.gender, isPickerField: true, pickerOptions: ["male", "female"])
                        }
                        DetailBox(iconName: "fur", title: "Coat Color", value: coatColor) {
                            self.showEditScreen(title: "Coat Color", value: self.coatColor)
                        }
                    }
                    HStack {
                        DetailBox(iconName: "scale", title: "Weight", value: "\(weight) lbs") {
                            self.showEditScreen(title: "Weight", value: "\(self.weight)", isNumberField: true)
                        }
                        DetailBox(iconName: "height", title: "Height", value: "\(height) in") {
                            self.showEditScreen(title: "Height", value: "\(self.height)", isNumberField: true)
                        }
                    }
                    HStack {
                        DetailBox(iconName: "length", title: "Length", value: "\(length) in") {
                            self.showEditScreen(title: "Length", value: "\(self.length)", isNumberField: true)
                        }
                        DetailBox(iconName: "height1", title: "Coat Length", value: coatLength) {
                            self.showEditScreen(title: "Coat Length", value: self.coatLength)
                        }
                    }
                    HStack {
                        DetailBox(iconName: "comb", title: "Coat Type", value: coatType) {
                            self.showEditScreen(title: "Coat Type", value: self.coatType)
                        }
                        DetailBox(iconName: "dog", title: "Fitness Level", value: fitnessLevel) {
                            self.showEditScreen(title: "Fitness Level", value: self.fitnessLevel)
                        }
                    }
                }
                
                Spacer()

                NavigationLink(destination: PersonalitySelectionView(pet: updatedPet)) {
                    Text("Next")
                        .font(.custom("Nunito", size: 20))
                        .foregroundColor(.darkBackground)
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 60)
                        .background(Color.actionColor)
                        .cornerRadius(50)
                }
                .padding(.bottom, 8) // Further decrease bottom padding to reduce space between confirm button and detail boxes
            }
            .padding()

            if showingEditScreen {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                EditDetailView(isShowing: $showingEditScreen, title: editTitle, value: $editValue, isNumberField: isNumberField, isPickerField: isPickerField, pickerOptions: pickerOptions)
                    .onDisappear {
                        self.updateValue()
                    }
            }
        }
        .navigationBarHidden(true)
    }

    private func showEditScreen(title: String, value: String, isNumberField: Bool = false, isPickerField: Bool = false, pickerOptions: [String] = []) {
        self.editTitle = title
        self.editValue = value
        self.isNumberField = isNumberField
        self.isPickerField = isPickerField
        self.pickerOptions = pickerOptions
        self.showingEditScreen = true
    }

    private func updateValue() {
        switch editTitle {
        case "Primary Breed":
            self.primaryBreed = editValue
            self.updatedPet.primaryBreed = editValue
        case "Secondary Breed":
            self.secondaryBreed = editValue
            self.updatedPet.secondaryBreed = editValue
        case "Gender":
            self.gender = editValue
            self.updatedPet.gender = editValue
        case "Coat Color":
            self.coatColor = editValue
            self.updatedPet.coatColor = editValue
        case "Weight":
            if let weight = Double(editValue) {
                self.weight = weight
                self.updatedPet.weight = weight
            }
        case "Height":
            if let height = Double(editValue) {
                self.height = height
                self.updatedPet.height = height
            }
        case "Length":
            if let length = Double(editValue) {
                self.length = length
                self.updatedPet.length = length
            }
        case "Coat Length":
            self.coatLength = editValue
            self.updatedPet.coatLength = editValue
        case "Coat Type":
            self.coatType = editValue
            self.updatedPet.coatType = editValue
        case "Fitness Level":
            self.fitnessLevel = editValue
            self.updatedPet.fitnessLevel = editValue
        default:
            break
        }
    }
}

struct DetailBox: View {
    let iconName: String
    let title: String
    let value: String
    let action: () -> Void

    var body: some View {
        ZStack {
            Image("detailbox") // Use the name of your detail box image asset
                .resizable()
                .frame(width: UIScreen.main.bounds.width * 0.45, height: 80) // Adjust width and height as needed
            
            VStack(spacing: 8) {
                HStack {
                    Image("pencil") // Use the name of your pencil icon image asset
                        .resizable()
                        .frame(width: 20, height: 20)
                        .offset(x: -20, y: 0)
                        .onTapGesture {
                            self.action()
                        }
                    Spacer()
                }
                
                HStack {
                    Image(iconName) // Use the name of your icon image asset
                        .resizable()
                        .frame(width: 30, height: 30)
                        .offset(x: -5, y: -2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(value)
                            .font(.custom("Outfit", size: 16))
                            .foregroundColor(Color.actionColor)
                            .fontWeight(.black)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                        Text(title)
                            .font(.custom("Nunito", size: 14))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    }
                    
                    Spacer()
                }
                .padding(.leading, 8)
                .padding(.trailing, 8)
                
                Spacer()
            }
            .padding()
        }
    }
}

import SwiftUI

struct EditDetailView: View {
    @Binding var isShowing: Bool
    let title: String
    @Binding var value: String
    let isNumberField: Bool
    let isPickerField: Bool
    let pickerOptions: [String]
    
    @State private var tempValue: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                HStack {
                    Text(title)
                        .font(.custom("Nunito", size: 20))
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.top, 16)
                
                if isPickerField {
                    HStack(spacing: 8) {
                        ForEach(pickerOptions, id: \.self) { option in
                            Text(option)
                                .font(.custom("Nunito", size: 18))
                                .foregroundColor(self.tempValue == option ? .white : .black)
                                .padding()
                                .frame(width: 100, height: 40) // Ensuring equal size
                                .background(self.tempValue == option ? Color.blue : Color.gray.opacity(0.5))
                                .cornerRadius(20)
                                .onTapGesture {
                                    self.tempValue = option
                                }
                        }
                    }
                    .padding(.horizontal, 8)
                    .onAppear {
                        self.tempValue = self.value
                    }
                } else if isNumberField {
                    TextField("Enter \(title.lowercased())", text: $tempValue)
                        .keyboardType(.decimalPad)
                        .font(.custom("Nunito", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                        .onAppear {
                            self.tempValue = self.value
                        }
                } else {
                    TextField("Enter \(title.lowercased())", text: $tempValue)
                        .font(.custom("Nunito", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                        .onAppear {
                            self.tempValue = self.value
                        }
                }
                
                HStack {
                    Button(action: {
                        self.isShowing = false
                    }) {
                        Text("Cancel")
                            .font(.custom("Nunito", size: 18))
                            .foregroundColor(.blue)
                            .frame(width: 100, height: 40)
                            .background(Color.clear)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.value = self.tempValue
                        self.isShowing = false
                    }) {
                        Text("Save")
                            .font(.custom("Nunito", size: 18))
                            .foregroundColor(.darkBackground)
                            .frame(width: 100, height: 40)
                            .background(Color.actionColor)
                            .cornerRadius(20)
                    }
                }
                .padding(.bottom, 16)
            }
            .padding()
            .background(Color.black)
            .cornerRadius(16)
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .onAppear {
            self.tempValue = self.value
        }
    }
}
/*struct ConfirmPetInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePet = Pet(
            id: UUID(),
            name: "Fred",
            primaryBreed: "Labrador Retriever",
            secondaryBreed: "None",
            height: 60.0,
            weight: 30.0,
            length: 80.0,
            gender: "male",
            coatLength: "medium",
            coatType: "curly",
            coatColor: "black",
            age: 2,
            fitnessLevel: "ideal",
            animalType: "dog",
            imagePath: "" // Add a valid image path if needed
            //imageURL: URL(string: "https://example.com/image.jpg")!
        )
        
        ConfirmPetInfoView(pet: samplePet)
    }
}*/

struct PersonalitySelectionView: View {
    @State private var selectedPersonality: String = ""
    var pet: Pet
    let personalities = ["Friendly", "Energetic", "Calm", "Playful", "Loyal", "Assertive", "Intelligent", "Bold", "Independent"]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 8) {
                Text("Select a personality trait that best describes \(pet.name)")
                    .font(.custom("Nunito", size: 20))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)

                VStack(spacing: 10) {
                    ForEach(personalities, id: \.self) { personality in
                        HStack {
                            Text(personality)
                                .font(.custom("Outfit", size: 18))
                                .foregroundColor(selectedPersonality == personality ? .darkBackground : .white)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedPersonality == personality ? Color.actionColor : Color.darkBackground)
                                .cornerRadius(10)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPersonality = personality
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)

                Spacer()

                NavigationLink(destination: BirthdaySelectionView(pet: pet, selectedPersonality: selectedPersonality)) {
                    Text("Confirm")
                        .font(.custom("Nunito", size: 20))
                        .foregroundColor(.darkBackground)
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 60)
                        .background(selectedPersonality.isEmpty ? Color.gray : Color.actionColor)
                        .cornerRadius(50)
                }
                .disabled(selectedPersonality.isEmpty)
                .padding(.bottom, 20)
            }
            .padding()
        }
        //.navigationTitle("Select Personality")
        //.navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
    }
}

import SwiftUI

struct BirthdaySelectionView: View {
    @State private var selectedDate = Date()
    @State private var showCardView = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var updatedPet: Pet?
    var pet: Pet
    var selectedPersonality: String

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                
                Spacer()

                Text("Select \(pet.name)'s birthday")
                    .font(.custom("Nunito", size: 20))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
                    .background(Color.darkBackground)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)

                if isLoading {
                    ProgressView("Updating...")
                        .padding()
                }

                Spacer()

                Button(action: {
                    savePetAndNavigate()
                }) {
                    Text("Confirm")
                        .font(.custom("Nunito", size: 20))
                        .foregroundColor(.darkBackground)
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 60)
                        .background(Color.actionColor)
                        .cornerRadius(50)
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .background(
            NavigationLink(
                destination: CardView(pet: updatedPet ?? pet),
                isActive: $showCardView,
                label: {
                    EmptyView()
                }
            )
        )
    }

    private func savePetAndNavigate() {
        var updatedPet = pet
        updatedPet.birthday = selectedDate
        updatedPet.zodiacSign = calculateZodiacSign(for: selectedDate)
        updatedPet.age = calculateAge(from: selectedDate)
        updatedPet.personality = selectedPersonality

        savePet(updatedPet)

        // Set the updated pet
        self.updatedPet = updatedPet

        // Perform the navigation
        showCardView = true

        // Perform the API call in the background
        updatePetInfo(pet: updatedPet)
    }

    private func calculateZodiacSign(for date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month], from: date)
        let day = components.day!
        let month = components.month!
        
        switch (month, day) {
        case (1, 20...31), (2, 1...18):
            return "Aquarius"
        case (2, 19...29), (3, 1...20):
            return "Pisces"
        case (3, 21...31), (4, 1...19):
            return "Aries"
        case (4, 20...30), (5, 1...20):
            return "Taurus"
        case (5, 21...31), (6, 1...20):
            return "Gemini"
        case (6, 21...30), (7, 1...22):
            return "Cancer"
        case (7, 23...31), (8, 1...22):
            return "Leo"
        case (8, 23...31), (9, 1...22):
            return "Virgo"
        case (9, 23...30), (10, 1...22):
            return "Libra"
        case (10, 23...31), (11, 1...21):
            return "Scorpio"
        case (11, 22...30), (12, 1...21):
            return "Sagittarius"
        case (12, 22...31), (1, 1...19):
            return "Capricorn"
        default:
            return "Unknown"
        }
    }

    private func calculateAge(from birthday: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        return ageComponents.year!
    }

    private func savePet(_ pet: Pet) {
        var pets = fetchPets()
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[index] = pet
        } else {
            pets.append(pet)
        }

        if let encodedData = try? JSONEncoder().encode(pets) {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent("pets.json")
            try? encodedData.write(to: fileURL)
        }
    }

    private func fetchPets() -> [Pet] {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("pets.json")

        if let data = try? Data(contentsOf: fileURL),
           let pets = try? JSONDecoder().decode([Pet].self, from: data) {
            return pets
        }

        return []
    }

    private func updatePetInfo(pet: Pet) {
        OpenAIAPI.shared.updatePetInfo(userId: pet.userId, petId: pet.petId, pet: pet) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    print("Pet info updated successfully")
                case .failure(let error):
                    print("Error updating pet info: \(error.localizedDescription)")
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}
