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
    let fm = FileManager.default
    let cwd = fm.currentDirectoryPath
    let templatesDir = URL(fileURLWithPath: cwd).appendingPathComponent("LightroomTemplates")

    // Destination folders (macOS-specific)
    let destBase = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/Adobe/Lightroom")

    let templateSubfolders = [
        "Filename Templates",
        "Import Presets",
        "Keyword Sets",
        "Label Sets",
        "Local Adjustment Presets",
        "Metadata Presets",
        "Tone Curve Presets",
        "Develop Presets",
        "Export Presets",
        "Watermarks"
    ]

    // Replace placeholders
    let placeholders: [String: String] = [
        "{{FIRST}}": firstName,
        "{{LAST}}": lastName,
        "{{NICKNAME}}": nickname
    ]

    statusMessages.append("📁 Starting template generation...")

    guard fm.fileExists(atPath: templatesDir.path) else {
        statusMessages.append("❌ Template source folder not found: \(templatesDir.path)")
        return
    }

    for subfolder in templateSubfolders {
        let sourcePath = templatesDir.appendingPathComponent(subfolder)
        let destPath = destBase.appendingPathComponent(subfolder)

        do {
            if !fm.fileExists(atPath: destPath.path) {
                try fm.createDirectory(at: destPath, withIntermediateDirectories: true)
            }

            let files = try fm.contentsOfDirectory(atPath: sourcePath.path)

            for file in files {
                let fileURL = sourcePath.appendingPathComponent(file)

                // Read file contents
                var contents = try String(contentsOf: fileURL, encoding: .utf8)

                // Replace placeholders
                for (tag, value) in placeholders {
                    contents = contents.replacingOccurrences(of: tag, with: value)
                }

                // Rename file if needed
                var outputFilename = file
                if file.contains("{{NICKNAME}}") || file.contains("{{FIRST}}") {
                    outputFilename = file
                    for (tag, value) in placeholders {
                        outputFilename = outputFilename.replacingOccurrences(of: tag, with: value)
                    }
                }

                let outputURL = destPath.appendingPathComponent(outputFilename)

                // Warn if overwriting
                if fm.fileExists(atPath: outputURL.path) {
                    statusMessages.append("⚠️ Overwriting existing file: \(outputURL.lastPathComponent)")
                }

                try contents.write(to: outputURL, atomically: true, encoding: .utf8)
                statusMessages.append("✅ Created: \(outputFilename)")
            }

        } catch {
            statusMessages.append("❌ Error processing \(subfolder): \(error.localizedDescription)")
        }
    }

    // Rename all catalog files
    let catalogDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Pictures/Lightroom")

    let oldPrefix = "Lightroom Catalog"
    let newPrefix = "\(firstName) \(lastName)"

    do {
        let files = try fm.contentsOfDirectory(atPath: catalogDir.path)

        for file in files {
            if file.hasPrefix(oldPrefix) {
                let newName = file.replacingOccurrences(of: oldPrefix, with: newPrefix)
                let oldURL = catalogDir.appendingPathComponent(file)
                let newURL = catalogDir.appendingPathComponent(newName)

                if !fm.fileExists(atPath: newURL.path) {
                    try fm.moveItem(at: oldURL, to: newURL)
                    statusMessages.append("🔁 Renamed: \(file) → \(newName)")
                } else {
                    statusMessages.append("⚠️ Skipped rename: \(newName) already exists")
                }
            }
        }
    } catch {
        statusMessages.append("❌ Catalog renaming failed: \(error.localizedDescription)")
    }

    statusMessages.append("🎉 All done, you glorious beast.")
}
