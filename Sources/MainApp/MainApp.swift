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
    @State private var nickname = ""
    @State private var statusMessages: [String] = []

    var body: some View {
        VStack(spacing: 15) {
            Text("Lightroom Templates Generator")
                .font(.title2)
                .padding()

            TextField("First Name", text: $firstName)
                .textFieldStyle(.roundedBorder)

            TextField("Last Name", text: $lastName)
                .textFieldStyle(.roundedBorder)

            TextField("Nickname", text: $nickname)
                .textFieldStyle(.roundedBorder)

            Button("Submit") {
                handleSubmit()
            }
            .disabled(firstName.isEmpty || lastName.isEmpty || nickname.isEmpty)

            ScrollView {
                ForEach(statusMessages, id: \.self) { message in
                    Text(message)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(message.contains("❌") ? .red : .green)
                }
            }
            .frame(height: 150)
            .padding(.top, 10)
        }
        .padding()
        .frame(width: 420, height: 420)
    }

    func handleSubmit() {
        statusMessages.removeAll()

        let replacements = [
            "{{FIRST}}": firstName,
            "{{LAST}}": lastName,
            "{{NICKNAME}}": nickname
        ]

        // Template processing
        let fileManager = FileManager.default
        let homeDir = fileManager.homeDirectoryForCurrentUser
        let targetDir = homeDir.appendingPathComponent("Library/Application Support/Adobe/Lightroom")

        guard fileManager.fileExists(atPath: targetDir.path) else {
            statusMessages.append("❌ Template target folder not found: \(targetDir.path)")
            return
        }

        let templateFile1 = "Import Rename YYYY-MM-DD-{{NICKNAME}}-#.lrtemplate"
        let templateFile2 = "{{FIRST}} {{LAST}}.lrtemplate"

        let renamedFile1 = "Import Rename YYYY-MM-DD-\(nickname)-#.lrtemplate"
        let renamedFile2 = "\(firstName) \(lastName).lrtemplate"

        let bundledDir = Bundle.main.resourceURL?.appendingPathComponent("LightroomTemplates")
        guard let templateDir = bundledDir else {
            statusMessages.append("❌ Template processing failed: LightroomTemplates folder not found.")
            return
        }

        do {
            let contents = try fileManager.contentsOfDirectory(at: templateDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

            for file in contents {
                let filename = file.lastPathComponent
                let destinationName: String

                if filename == templateFile1 {
                    destinationName = renamedFile1
                } else if filename == templateFile2 {
                    destinationName = renamedFile2
                } else {
                    destinationName = filename
                }

                let destURL = targetDir.appendingPathComponent(destinationName)
                try? fileManager.removeItem(at: destURL)  // Overwrite
                try fileManager.copyItem(at: file, to: destURL)
            }

            statusMessages.append("✅ Templates installed in: \(targetDir.lastPathComponent)")
        } catch {
            statusMessages.append("❌ Error copying templates: \(error.localizedDescription)")
        }

        // Rename catalog files
        let catalogDir = homeDir.appendingPathComponent("Pictures/Lightroom")
        let catalogPrefix = "Lightroom Catalog"
        let newPrefix = "\(firstName) \(lastName)"

        do {
            let contents = try fileManager.contentsOfDirectory(at: catalogDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

            var foundCatalog = false
            for file in contents {
                let filename = file.lastPathComponent
                if filename.hasPrefix(catalogPrefix) {
                    foundCatalog = true
                    let suffix = filename.dropFirst(catalogPrefix.count)
                    let newName = newPrefix + suffix
                    let newURL = catalogDir.appendingPathComponent(newName)

                    try? fileManager.removeItem(at: newURL)
                    try fileManager.moveItem(at: file, to: newURL)
                }
            }

            if foundCatalog {
                statusMessages.append("📸 Catalog files renamed to: \(newPrefix)...")
            } else {
                statusMessages.append("⚠️ No catalog files named 'Lightroom Catalog' found. Nothing renamed.")
            }
        } catch {
            statusMessages.append("❌ Catalog renaming error: \(error.localizedDescription)")
        }

        statusMessages.append("🎉 Done!")
    }
}
