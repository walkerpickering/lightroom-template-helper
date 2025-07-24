import Foundation

struct TemplateProcessor {

    func run(firstName: String,
             lastName: String,
             city: String,
             state: String,
             zip: String,
             country: String,
             phone: String,
             email: String,
             nickname: String,
             login: String,
             hdname: String) -> [String] {

        var log: [String] = []

        // ---------------------------
        // 0) Build the replacement map
        // ---------------------------
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
            "{{HDNAME}}": hdname
        ]

        let fileManager = FileManager.default
        let home = fileManager.homeDirectoryForCurrentUser

        // ---------------------------
        // 1) Rename Lightroom Catalog files (ONLY if defaults exist)
        // ---------------------------
        let picturesLR = home.appendingPathComponent("Pictures/Lightroom")
        let defaultPrefix = "Lightroom Catalog"
        let newPrefix = "\(firstName) \(lastName)"

        do {
            let contents = try fileManager.contentsOfDirectory(at: picturesLR, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            let defaultCatalogs = contents.filter { $0.lastPathComponent.hasPrefix(defaultPrefix) }

            if defaultCatalogs.isEmpty {
                log.append("ℹ️ No default Lightroom catalog files found (starting with \"\(defaultPrefix)\"). Skipping rename.")
            } else {
                for oldURL in defaultCatalogs {
                    let newName = oldURL.lastPathComponent.replacingOccurrences(of: defaultPrefix, with: newPrefix)
                    let newURL = oldURL.deletingLastPathComponent().appendingPathComponent(newName)

                    if fileManager.fileExists(atPath: newURL.path) {
                        log.append("⚠️ Skipped rename (target exists): \(newURL.lastPathComponent)")
                        continue
                    }

                    do {
                        try fileManager.moveItem(at: oldURL, to: newURL)
                        log.append("✅ Renamed: \(oldURL.lastPathComponent) → \(newURL.lastPathComponent)")
                    } catch {
                        log.append("❌ Failed to rename \(oldURL.lastPathComponent): \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            log.append("❌ Could not scan Lightroom catalog directory: \(error.localizedDescription)")
        }

        // ---------------------------
        // 2) Copy & substitute template files
        // ---------------------------
        guard let resourceRoot = Bundle.main.resourceURL?.appendingPathComponent("LightroomTemplates"),
              fileManager.fileExists(atPath: resourceRoot.path) else {
            log.append("❌ Template processing failed: Couldn’t find LightroomTemplates in app bundle Resources.")
            log.append("Done (with errors)")
            return log
        }

        let destRoot = home
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
            .appendingPathComponent("Adobe")
            .appendingPathComponent("Lightroom")

        // Mirror the directory tree found in Resources/LightroomTemplates
        if let enumerator = fileManager.enumerator(at: resourceRoot, includingPropertiesForKeys: nil) {
            while let srcURL = enumerator.nextObject() as? URL {
                let relPath = srcURL.path.replacingOccurrences(of: resourceRoot.path + "/", with: "")

                // Skip .DS_Store and directories
                if srcURL.lastPathComponent == ".DS_Store" { continue }

                var isDir: ObjCBool = false
                fileManager.fileExists(atPath: srcURL.path, isDirectory: &isDir)
                if isDir.boolValue {
                    // make sure the destination dir exists
                    let dstDir = destRoot.appendingPathComponent(relPath)
                    do {
                        try fileManager.createDirectory(at: dstDir, withIntermediateDirectories: true)
                    } catch {
                        log.append("❌ Could not create directory \(dstDir.path): \(error.localizedDescription)")
                    }
                    continue
                }

                // It's a file — open, replace placeholders, and write out
                do {
                    let dstDirectory = destRoot.appendingPathComponent(relPath).deletingLastPathComponent()
                    if !fileManager.fileExists(atPath: dstDirectory.path) {
                        try fileManager.createDirectory(at: dstDirectory, withIntermediateDirectories: true)
                    }

                    // Replace placeholders in filename too
                    let replacedFilename = replace(URL(fileURLWithPath: relPath).lastPathComponent, with: replacements)
                    let dstURL = dstDirectory.appendingPathComponent(replacedFilename)

                    // Read file as text (templates are text files)
                    let original = try String(contentsOf: srcURL, encoding: .utf8)
                    let substituted = replace(original, with: replacements)

                    // Warn if overwriting
                    if fileManager.fileExists(atPath: dstURL.path) {
                        log.append("⚠️ Overwriting: \(dstURL.path)")
                    } else {
                        log.append("✅ Creating: \(dstURL.path)")
                    }

                    try substituted.write(to: dstURL, atomically: true, encoding: .utf8)

                } catch {
                    log.append("❌ Error processing \(srcURL.lastPathComponent): \(error.localizedDescription)")
                }
            }
        } else {
            log.append("❌ Could not enumerate LightroomTemplates directory.")
        }

        log.append("Done")
        return log
    }

    // MARK: - Helpers

    private func replace(_ text: String, with map: [String: String]) -> String {
        var out = text
        for (k, v) in map {
            out = out.replacingOccurrences(of: k, with: v)
        }
        return out
    }
}
