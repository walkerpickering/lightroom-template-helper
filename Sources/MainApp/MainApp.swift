import SwiftUI

@main
struct LightroomTemplateHelperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

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
    @State private var login = ""
    @State private var hdname = ""
    @State private var availableDrives: [String] = []

    var allFieldsFilled: Bool {
        return !firstName.isEmpty &&
               !lastName.isEmpty &&
               !city.isEmpty &&
               !state.isEmpty &&
               !zip.isEmpty &&
               !country.isEmpty &&
               !phone.isEmpty &&
               !email.isEmpty &&
               !nickname.isEmpty &&
               !login.isEmpty &&
               !hdname.isEmpty
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Lightroom Templates Generator")
                .font(.title2)
                .padding(.top)

            Text("Fill in your personal information. All fields are required for this tool to work properly.")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 10)

            Group {
                VStack(alignment: .leading, spacing: 4) {
                    Text("First Name")
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last Name")
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("City")
                    TextField("City", text: $city)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("State")
                    TextField("State", text: $state)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("ZIP Code")
                    TextField("ZIP", text: $zip)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Country")
                    Picker("Country", selection: $country) {
                        Text("US").tag("US")
                        Text("Canada").tag("Canada")
                        Text("Mexico").tag("Mexico")
                        Text("Other").tag("Other")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Phone Number")
                    TextField("Phone", text: $phone)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Email Address")
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nickname")
                    TextField("Nickname", text: $nickname)
                        .textFieldStyle(.roundedBorder)
                    Text("Choose a short, lowercase nickname. This will serve to personalize your imported files in Lightroom. (e.g. – I use \"wpick\")")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("UNL Login")
                    TextField("Login", text: $login)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Your External Hard Drive Name")
                        Spacer()
                        Button("Refresh Drives") {
                            refreshDrives()
                        }
                        .font(.caption)
                    }
                    Picker("Select Drive", selection: $hdname) {
                        ForEach(availableDrives, id: \.self) { drive in
                            Text(drive).tag(drive)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Text("The name of your external hard drive. Be precise — this is required.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
            }

            Button("Submit") {
                handleSubmit()
            }
            .disabled(!allFieldsFilled)
            .padding(.top)
        }
        .padding()
        .frame(width: 480)
        .onAppear(perform: refreshDrives)
    }

    func refreshDrives() {
        let fm = FileManager.default
        let keys: [URLResourceKey] = [.volumeIsRemovableKey, .volumeNameKey]
        if let urls = fm.mountedVolumeURLs(includingResourceValuesForKeys: keys, options: []) {
            let drives = urls.compactMap { url -> String? in
                if let values = try? url.resourceValues(forKeys: Set(keys)),
                   values.volumeIsRemovable == true {
                    return values.volumeName
                }
                return nil
            }
            availableDrives = drives
            if drives.count == 1 {
                hdname = drives[0]
            }
        }
    }

    func handleSubmit() {
        print("Form submitted with:")
        print("FIRST: \(firstName), LAST: \(lastName), CITY: \(city), STATE: \(state)")
        print("ZIP: \(zip), COUNTRY: \(country), PHONE: \(phone), EMAIL: \(email)")
        print("NICKNAME: \(nickname), LOGIN: \(login), HDNAME: \(hdname)")
        // Placeholder — real file logic already wired in separately
    }
}
