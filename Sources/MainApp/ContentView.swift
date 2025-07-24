import Foundation
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
    @State private var hdname = ""
    @State private var externalDrives: [String] = []
    @State private var statusMessages: [String] = []
    @State private var isSubmitting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lightroom Templates Generator")
                .font(.title2)
                .padding(.bottom, 5)

            Text("Fill in your personal information. All fields are required for this tool to work properly.")
                .font(.subheadline)

            Group {
                FormField(label: "First Name", text: $firstName, onChange: generateNickname)
                FormField(label: "Last Name", text: $lastName, onChange: generateNickname)
                FormField(label: "City", text: $city)
                FormField(label: "State", text: $state)
                FormField(label: "Zip Code", text: $zip)
                FormField(label: "Country", text: $country)
                FormField(label: "Phone Number", text: $phone)
                FormField(label: "Email Address", text: $email)
                FormField(label: "Nickname", text: $nickname)
                FormField(label: "Computer Username", text: $login, isEditable: false)
            }

            HStack {
                Picker("External Hard Drive", selection: $hdname) {
                    ForEach(externalDrives, id: \.self) { drive in
                        Text(drive).tag(drive)
                    }
                }
                Button("Refresh Drives") {
                    externalDrives = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil)?
                        .compactMap { $0.pathComponents.last }
                        .filter { !$0.isEmpty } ?? []
                }
            }

            Button("Submit") {
                handleSubmit()
            }
            .disabled(!allFieldsFilled())
            .padding(.top, 10)

            Divider().padding(.vertical, 10)

            VStack(alignment: .leading) {
                ForEach(statusMessages, id: \.self) { msg in
                    Text(msg)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                }
            }

        }
        .padding()
        .frame(width: 500)
        .onAppear {
            login = NSUserName()
            externalDrives = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil)?
                .compactMap { $0.pathComponents.last }
                .filter { !$0.isEmpty } ?? []
        }
    }

    private func generateNickname(_ input: String = "") {
        let first = firstName.lowercased()
        let last = lastName.lowercased()
        if !first.isEmpty && !last.isEmpty {
            nickname = "\(first.prefix(1))\(last)"
        }
    }

    private func allFieldsFilled() -> Bool {
        return !firstName.isEmpty && !lastName.isEmpty && !city.isEmpty &&
            !state.isEmpty && !zip.isEmpty && !country.isEmpty &&
            !phone.isEmpty && !email.isEmpty && !nickname.isEmpty &&
            !login.isEmpty && !hdname.isEmpty
    }

    private func handleSubmit() {
        statusMessages = ["⏳ Starting..."]

        let result = TemplateProcessor().run(
            firstName: firstName,
            lastName: lastName,
            city: city,
            state: state,
            zip: zip,
            country: country,
            phone: phone,
            email: email,
            nickname: nickname,
            login: login,
            hdname: hdname
        )

        for line in result {
            statusMessages.append(line)
        }

        if result.last?.contains("Done") == true {
            statusMessages.append("🎉 All tasks completed!")
        }
    }
}

struct FormField: View {
    var label: String
    @Binding var text: String
    var isEditable: Bool = true
    var onChange: ((String) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
            TextField("", text: $text)
                .textFieldStyle(.roundedBorder)
                .disabled(!isEditable)
                .onChange(of: text) { newValue in
                    onChange?(newValue)
                }
        }
    }
}
