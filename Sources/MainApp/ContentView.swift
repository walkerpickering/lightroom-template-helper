import SwiftUI

struct ContentView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var nickname = ""

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
                print("First: \(firstName), Last: \(lastName), Nick: \(nickname)")
            }
            .disabled(firstName.isEmpty || lastName.isEmpty || nickname.isEmpty)
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}
