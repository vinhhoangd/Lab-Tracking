//
//  LabItem.swift
//  Lab Tracking
//
//  Created by Vinh Hoang Duc on 5/26/25.
//

import Foundation
import FirebaseFirestore

struct LabItem: Identifiable, Codable {
    @DocumentID var docID: String?
    var id: String            // Mã barcode / QR code
    var name: String
    var type: String
    var createdAt: Date
    var createdBy: String
}
