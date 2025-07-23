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
        VStack(spacing: 20) {
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
                statusMessages = []
                handleSubmit()
            }
            .disabled(firstName.isEmpty || lastName.isEmpty || nickname.isEmpty)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(statusMessages, id: \.self) { message in
                        Text(message)
                            .font(.caption)
                            .foregroundColor(message.contains("❌") ? .red : .green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
        }
        .padding()
        .frame(width: 400, height: 500)
    }

    func handleSubmit() {
        let replacements: [String: String] = [
            "{{FIRST}}": firstName,
            "{{LAST}}": lastName,
            "{{NICKNAME}}": nickname
        ]

        // Paths
        let fileManager = FileManager.default
        let homeDir = fileManager.homeDirectoryForCurrentUser
        let sourceDir = homeDir.appendingPathComponent("LightroomTemplates")
        let destDir = homeDir
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
            .appendingPathComponent("Adobe")
            .appendingPathComponent("Lightroom")

        // Template file renaming logic
        do {
            let items = try fileManager.contentsOfDirectory(at: sourceDir, includingPropertiesForKeys: nil)
            for file in items {
                if file.pathExtension == "lrtemplate" {
                    var newName = file.lastPathComponent
                    for (placeholder, value) in replacements {
                        newName = newName.replacingOccurrences(of: placeholder, with: value)
                    }

                    let destFile = destDir.appendingPathComponent(newName)

                    if fileManager.fileExists(atPath: destFile.path) {
                        statusMessages.append("⚠️ Overwriting: \(newName)")
                    } else {
                        statusMessages.append("✅ Creating: \(newName)")
                    }

                    try? fileManager.copyItem(at: file, to: destFile)
                }
            }
        } catch {
            statusMessages.append("❌ Template processing failed: \(error.localizedDescription)")
        }

        // Catalog renaming logic
        let picturesDir = homeDir.appendingPathComponent("Pictures").appendingPathComponent("Lightroom")
        let defaultCatalog = picturesDir.appendingPathComponent("Lightroom Catalog.lrcat")
        let newCatalogName = "\(firstName) \(lastName).lrcat"
        let newCatalogPath = picturesDir.appendingPathComponent(newCatalogName)

        if fileManager.fileExists(atPath: defaultCatalog.path) {
            do {
                try fileManager.moveItem(at: defaultCatalog, to: newCatalogPath)
                statusMessages.append("📦 Catalog renamed to: \(newCatalogName)")
            } catch {
                statusMessages.append("❌ Failed to rename catalog: \(error.localizedDescription)")
            }
        } else {
            statusMessages.append("ℹ️ No default catalog found. Skipping rename.")
        }

        statusMessages.append("🎉 Done!")
    }
}
