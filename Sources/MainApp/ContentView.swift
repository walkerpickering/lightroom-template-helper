import SwiftUI

struct ContentView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zip = ""
    @State private var country = "US"
    @State private var phone = ""
    @State private var email = ""
    @State private var nickname = ""
    @State private var login = NSUserName()
    @State private var hdName = ""
    @State private var driveList: [String] = []
    @State private var statusMessages: [String] = []

    var body: some View {
        VStack(spacing: 10) {
            Text("Lightroom Templates Generator")
                .font(.title2)
                .padding(.top)

            Text("Fill in your personal information. All fields are required for this tool to work properly.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.bottom)

            FormField("First Name", text: $firstName, onChange: generateNickname)
            FormField("Last Name", text: $lastName, onChange: generateNickname)
            FormField("City", text: $city)
            FormField("State", text: $state)
            FormField("ZIP", text: $zip)
            FormField("Country", text: $country)
            FormField("Phone", text: $phone)
            FormField("Email", text: $email)
            FormField("Nickname", text: $nickname)
            HelpText("Choose a short, lowercase nickname. This will personalize your files. (e.g., wpick)")

            FormField("Computer Username", text: $login)
            HelpText("This should match your macOS account username.")

            HStack {
                Picker("External Hard Drive", selection: $hdName) {
                    ForEach(driveList, id: \.self) { drive in
                        Text(drive)
                    }
                }
                Button("Refresh Drives") {
                    refreshDrives()
                }
                .padding(.leading, 10)
            }
            HelpText("Select the name of your external drive where catalogs should be stored.")

            Button("Submit") {
                handleSubmit()
            }
            .disabled(!allFieldsFilled)
            .padding(.top)

            Divider().padding(.vertical, 10)

            ForEach(statusMessages, id: \.self) { msg in
                Text(msg)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .frame(width: 460, height: 720)
        .onAppear(perform: refreshDrives)
    }

    var allFieldsFilled: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty && !country.isEmpty && !phone.isEmpty && !email.isEmpty && !nickname.isEmpty && !login.isEmpty && !hdName.isEmpty
    }

    func generateNickname() {
        nickname = (firstName + lastName).lowercased()
    }

    func refreshDrives() {
        let fileManager = FileManager.default
        if let volumes = try? fileManager.contentsOfDirectory(atPath: "/Volumes") {
            driveList = volumes.filter { $0 != "Macintosh HD" }
            if driveList.contains(hdName) == false {
                hdName = driveList.first ?? ""
            }
        }
    }

    func handleSubmit() {
        statusMessages = []
        let result = TemplateProcessor().run(
            first: firstName,
            last: lastName,
            city: city,
            state: state,
            zip: zip,
            country: country,
            phone: phone,
            email: email,
            nickname: nickname,
            login: login,
            hdname: hdName
        )
        statusMessages.append(contentsOf: result)
    }
}

struct FormField: View {
    var label: String
    @Binding var text: String
    var onChange: (() -> Void)? = nil

    var body: some View {
        TextField(label, text: $text)
            .textFieldStyle(.roundedBorder)
            .onChange(of: text) { _ in onChange?() }
    }
}

struct HelpText: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)
    }
}
