import Foundation
import FirebaseFirestore

struct LabItem: Identifiable, Codable {
    @DocumentID var docID: String?
    var id: String
    var name: String
    var type: String
    var createdAt: Date
    var createdBy: String
}
