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
    @State private var hdName = ""
    @State private var statusMessages: [String] = []
    @State private var showCompletionOptions = false

    var isFormComplete: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !city.isEmpty &&
        !state.isEmpty &&
        !zip.isEmpty &&
        !country.isEmpty &&
        !phone.isEmpty &&
        !email.isEmpty &&
        !nickname.isEmpty &&
        !login.isEmpty &&
        !hdName.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lightroom Templates Generator")
                .font(.title)
                .padding(.bottom, 10)

            Group {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: firstName) { _ in generateNickname() }

                TextField("Last Name", text: $lastName)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: lastName) { _ in generateNickname() }

                TextField("City", text: $city).textFieldStyle(.roundedBorder)
                TextField("State", text: $state).textFieldStyle(.roundedBorder)
                TextField("Zip Code", text: $zip).textFieldStyle(.roundedBorder)
                TextField("Country", text: $country).textFieldStyle(.roundedBorder)
                TextField("Phone Number", text: $phone).textFieldStyle(.roundedBorder)
                TextField("Email Address", text: $email).textFieldStyle(.roundedBorder)

                TextField("Nickname", text: $nickname)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: nickname) { newValue in
                        nickname = newValue.filter { $0.isLetter || $0.isNumber }
                    }

                Text("Choose a short, lowercase nickname.").font(.caption).foregroundColor(.gray)

                TextField("Your Computer Username", text: $login).textFieldStyle(.roundedBorder)
                TextField("Your External Hard Drive Name", text: $hdName).textFieldStyle(.roundedBorder)
                Text("Make sure your external hard drive is connected before selecting.").font(.caption).foregroundColor(.gray)
            }

            Button("Submit") {
                statusMessages.removeAll()
                Task {
                    await runTemplateSetup()
                }
            }
            .disabled(!isFormComplete)
            .padding(.top, 10)

            Divider().padding(.vertical)

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(statusMessages, id: \.self) { message in
                        Text("• \(message)")
                            .font(.caption)
                            .foregroundColor(message.contains("Error") || message.contains("X") ? .red : .green)
                    }
                }
            }

            if showCompletionOptions {
                Divider().padding(.vertical, 5)
                Button("Quit and Delete App") {
                    deleteAppAndQuit()
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 480, height: 700)
    }

    func generateNickname() {
        let fn = firstName.lowercased().filter(\.isLetter)
        let ln = lastName.lowercased().filter(\.isLetter)
        nickname = fn.prefix(1) + ln
    }

    func runTemplateSetup() async {
        let replacements: [String: String] = [
            "{{FIRST}}": firstName,
            "{{LAST}}": lastName,
            "{{CITY}}": city,
            "{{STATE}}": state,
            "{{ZIP}}": zip,
            "{{COUNTRY}}": country,
            "{{PHONE}}": phone,
            "{{EMAIL}}": email,
            "{{NICKNAME}}": nickname,
            "{{LOGIN}}": login,
            "{{HDNAME}}": hdName
        ]

        // 1. Rename catalog files
        let pictures = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Pictures/Lightroom")
        let lrcatPrefix = "Lightroom Catalog"
        let newCatalogName = "\(firstName) \(lastName)"
        let catalogFiles = try? FileManager.default.contentsOfDirectory(at: pictures, includingPropertiesForKeys: nil)

        var foundLRCatalog = false
        catalogFiles?.forEach { file in
            if file.lastPathComponent.hasPrefix(lrcatPrefix) {
                foundLRCatalog = true
                let newFile = file.deletingLastPathComponent().appendingPathComponent(file.lastPathComponent.replacingOccurrences(of: lrcatPrefix, with: newCatalogName))
                try? FileManager.default.moveItem(at: file, to: newFile)
            }
        }

        if foundLRCatalog {
            statusMessages.append("✅ Catalog files renamed to: \(newCatalogName)...")
        } else {
            statusMessages.append("⚠️ No default catalog files found. Skipped renaming.")
        }

        // 2. Process and copy templates
        guard let templatePath = Bundle.main.resourcePath?.appending("/LightroomTemplates") else {
            statusMessages.append("❌ Template processing failed: Couldn't find resource folder.")
            return
        }

        let destinationRoot = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Adobe/Lightroom")

        let folders = [
            "Export Presets/UNL PHOT 161",
            "Filename Templates",
            "Import Presets/User Presets",
            "Metadata Preset",
            "Print Templates/User Templates"
        ]

        for folder in folders {
            let src = URL(fileURLWithPath: templatePath).appendingPathComponent(folder)
            let dst = destinationRoot.appendingPathComponent(folder)

            do {
                try FileManager.default.createDirectory(at: dst, withIntermediateDirectories: true)
                let files = try FileManager.default.contentsOfDirectory(at: src, includingPropertiesForKeys: nil)

                var willOverwrite = false
                for file in files {
                    let contents = try String(contentsOf: file)
                    let replaced = replacements.reduce(contents) { $0.replacingOccurrences(of: $1.key, with: $1.value) }

                    let filename = file.lastPathComponent
                        .replacingOccurrences(of: "{{FIRST}}", with: firstName)
                        .replacingOccurrences(of: "{{LAST}}", with: lastName)

                    let outputPath = dst.appendingPathComponent(filename)
                    if FileManager.default.fileExists(atPath: outputPath.path) { willOverwrite = true }

                    try replaced.write(to: outputPath, atomically: true, encoding: .utf8)
                }

                statusMessages.append("✅ Templates installed in: \(folder)")
                if willOverwrite {
                    statusMessages.append("⚠️ Some files were overwritten in \(folder)")
                }
            } catch {
                statusMessages.append("❌ Error copying to \(folder): \(error.localizedDescription)")
            }
        }

        // 3. Show final option
        statusMessages.append("🎉 Done!")
        showCompletionOptions = true
    }

    func deleteAppAndQuit() {
        let fm = FileManager.default
        let appPath = Bundle.main.bundleURL

        // Check if it's inside "LightroomTemplateApp" folder
        let parent = appPath.deletingLastPathComponent()
        if parent.lastPathComponent == "LightroomTemplateApp" {
            try? fm.removeItem(at: parent)
        } else {
            try? fm.removeItem(at: appPath)
        }

        NSApp.terminate(nil)
    }
}
