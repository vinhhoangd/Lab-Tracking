import SwiftUI
import FirebaseFirestore

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode

    var scannedCode: String
    @State private var name = ""
    @State private var id = ""
    @State private var type = "Tube"
    
    let types = ["Tube", "Vial", "Machine", "Chemicals", "Other"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Scanned Code")) {
                    Text(scannedCode)
                }

                Section(header: Text("Item Info")) {
                    TextField("Name", text: $name)
                    TextField("ID", text: $id)
                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) {
                            Text($0)
                        }
                    }
                }
            }
            .navigationBarTitle("Add Item", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                saveItemToFirebase()
            })
        }
    }

    func saveItemToFirebase() {
        let db = Firestore.firestore()
        let newItem: [String: Any] = [
            "code": scannedCode,
            "name": name,
            "id": id,
            "type": type,
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("labItems").document(scannedCode).setData(newItem) { error in
            if let error = error {
                print("Error saving item: \(error.localizedDescription)")
            } else {
                print("Item saved successfully")
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
