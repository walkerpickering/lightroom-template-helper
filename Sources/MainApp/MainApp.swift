import SwiftUI

@main
struct LightroomTemplateHelperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct TaskStatus: Identifiable {
    let id = UUID()
    let message: String
    let isSuccess: Bool
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

    @State private var taskStatuses: [TaskStatus] = []
    @State private var showQuitOption = false

    var formComplete: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty &&
        !country.isEmpty && !phone.isEmpty && !email.isEmpty &&
        !nickname.isEmpty && !login.isEmpty && !hdname.isEmpty
    }

    var body: some View {
        VStack(spacing: 10) {
            Text("Lightroom Templates Generator")
                .font(.title2)
                .padding()

            Group {
                TextField("First Name", text: $firstName)
                    .onChange(of: firstName) { _ in updateNickname() }

                TextField("Last Name", text: $lastName)
                    .onChange(of: lastName) { _ in updateNickname() }

                TextField("City", text: $city)
                TextField("State", text: $state)
                TextField("ZIP Code", text: $zip)
                TextField("Country", text: $country)
                TextField("Phone Number", text: $phone)
                TextField("Email Address", text: $email)

                TextField("Nickname", text: $nickname)
                Text("Choose a short, lowercase nickname.").font(.caption).foregroundColor(.gray)

                TextField("Your Computer Username", text: $login)
                TextField("Your External Hard Drive Name", text: $hdname)
                Text("Make sure your external hard drive is connected before selecting.").font(.caption).foregroundColor(.gray)
            }
            .textFieldStyle(.roundedBorder)

            Button("Submit") {
                handleSubmit()
            }
            .disabled(!formComplete)

            Divider().padding(.vertical, 5)

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(taskStatuses) { status in
                        Text((status.isSuccess ? "✅" : "❌") + " " + status.message)
                            .foregroundColor(status.isSuccess ? .green : .red)
                    }
                }
            }

            if showQuitOption {
                Divider().padding(.vertical, 5)

                Button("Quit and Delete App") {
                    quitAndDelete()
                }
                .foregroundColor(.red)
            }

        }
        .padding()
        .frame(width: 480, height: 700)
    }

    private func updateNickname() {
        let safeFirst = firstName.trimmingCharacters(in: .whitespaces).lowercased()
        let safeLast = lastName.trimmingCharacters(in: .whitespaces).lowercased()
        let guess = safeFirst.prefix(1) + safeLast
        let safe = guess.replacingOccurrences(of: "[^a-z0-9_-]", with: "", options: .regularExpression)
        if nickname.isEmpty { nickname = safe }
    }

    private func handleSubmit() {
        taskStatuses = []

        runShellScript(arguments: [
            firstName, lastName, city, state, zip, country, phone, email, nickname, login, hdname
        ])
    }

    private func runShellScript(arguments: [String]) {
        let task = Process()
        task.launchPath = Bundle.main.path(forResource: "template_script", ofType: "sh") // Your shell script
        task.arguments = arguments

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        task.launch()
        task.waitUntilExit()

        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        parseScriptOutput(output)
    }

    private func parseScriptOutput(_ output: String) {
        let lines = output.split(separator: "\n")
        for line in lines {
            let str = String(line)
            if str.starts(with: "✅") {
                taskStatuses.append(TaskStatus(message: str.dropFirst(2).description, isSuccess: true))
            } else if str.starts(with: "❌") {
                taskStatuses.append(TaskStatus(message: str.dropFirst(2).description, isSuccess: false))
            }
        }

        if taskStatuses.allSatisfy({ $0.isSuccess }) {
            showQuitOption = true
        }
    }

    private func quitAndDelete() {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", """
        APP_PATH="$(dirname "$(dirname "$0")")"
        rm -rf "$APP_PATH"
        osascript -e 'tell application "System Events" to quit application "Lightroom Templates Generator"'
        """]
        task.launch()
    }
}
