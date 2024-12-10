//
//  dataModel.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 02/12/24.
//

import Foundation
import FirebaseFirestore

// Struct for holding user registration data
struct UserRegistrationData {
    var profilePicture: UIImage? = nil
    var profilePictureURL: String? = nil
    var username: String = ""
    var dateOfBirth: String = ""
    var email: String = ""
    var contactNumber: String = ""
    var password: String = ""
    var dailyTarget: Int16 = 0
}

class User {
    var userId: String
    var username: String
    var email: String
    var passwordHash: String
    var profilePicture: String?
    var dailyTarget: Int16
    var totalMinutes: Int32
    var totalPoints: Int32
    var createdAt: Date
    var dateOfBirth: Date
    var contactNumber: String
    var dailyMinutes: Int32
    var dailyPoints: Int32
    var lastActivityDate: Date
    
    // MARK: - Initializer to Parse Data from Firestore
    init?(data: [String: Any]) {
        guard let userId = data["userId"] as? String,
              let username = data["username"] as? String,
              let email = data["email"] as? String,
              let passwordHash = data["passwordHash"] as? String,
              let dailyTarget = data["dailyTarget"] as? Int16,
              let totalMinutes = data["totalMinutes"] as? Int32,
              let totalPoints = data["totalPoints"] as? Int32,
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue(),
              let contactNumber = data["contactNumber"] as? String,
              let dailyMinutes = data["dailyMinutes"] as? Int32,
              let dailyPoints = data["dailyPoints"] as? Int32,
              let lastActivityDate = (data["lastActivityDate"] as? Timestamp)?.dateValue() else {
            print("Failed to parse required fields: \(data)")  // Log if any field is missing or improperly typed
            return nil
        }
        
        // Handle the `dateOfBirth` field which could be either a `Timestamp` or `String`
        var dateOfBirth: Date?
        if let timestamp = data["dateOfBirth"] as? Timestamp {
            dateOfBirth = timestamp.dateValue()
        } else if let dateString = data["dateOfBirth"] as? String {
            let dateFormatter = DateFormatter()
            // Ensure the format matches your Firestore string format, e.g., "13 January 2003"
            dateFormatter.dateFormat = "dd MMMM yyyy"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")  // Ensures month names are parsed correctly
            dateOfBirth = dateFormatter.date(from: dateString)
        }

        guard let finalDateOfBirth = dateOfBirth else {
            print("Failed to parse dateOfBirth: \(data["dateOfBirth"] ?? "nil")")
            return nil
        }

        // Initialize properties
        self.userId = userId
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.profilePicture = data["profilePicture"] as? String ?? ""  // Handle missing profilePicture gracefully
        self.dailyTarget = dailyTarget
        self.totalMinutes = totalMinutes
        self.totalPoints = totalPoints
        self.createdAt = createdAt
        self.dateOfBirth = finalDateOfBirth
        self.contactNumber = contactNumber
        self.dailyMinutes = dailyMinutes
        self.dailyPoints = dailyPoints
        self.lastActivityDate = lastActivityDate
    }
    
    // MARK: - Full Initializer (for Firestore creation)
    init(userId: String, username: String, email: String, passwordHash: String, profilePicture: String?, dailyTarget: Int16, totalMinutes: Int32, totalPoints: Int32, createdAt: Date, dateOfBirth: Date, contactNumber: String, dailyMinutes: Int32, dailyPoints: Int32, lastActivityDate: Date) {
        self.userId = userId
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.profilePicture = profilePicture
        self.dailyTarget = dailyTarget
        self.totalMinutes = totalMinutes
        self.totalPoints = totalPoints
        self.createdAt = createdAt
        self.dateOfBirth = dateOfBirth
        self.contactNumber = contactNumber
        self.dailyMinutes = dailyMinutes
        self.dailyPoints = dailyPoints
        self.lastActivityDate = lastActivityDate
    }
    
    // MARK: - Simplified Initializer for Defaults or Quick Setup
    init(username: String, totalPoints: Int32 = 0) {
        self.userId = "" // Placeholder or empty string, can be set later
        self.username = username
        self.email = "" // Placeholder
        self.passwordHash = "" // Placeholder
        self.profilePicture = nil
        self.dailyTarget = 0
        self.totalMinutes = 0
        self.totalPoints = totalPoints
        self.createdAt = Date() // Placeholder
        self.dateOfBirth = Date() // Placeholder
        self.contactNumber = "" // Placeholder
        self.dailyMinutes = 0
        self.dailyPoints = 0
        self.lastActivityDate = Date() // Placeholder
    }
    
    // Another simplified initializer (only username and userId)
    init(username: String, userId: String) {
        self.username = username
        self.userId = userId
        self.email = "" // Placeholder
        self.passwordHash = "" // Placeholder
        self.profilePicture = nil
        self.dailyTarget = 0
        self.totalMinutes = 0
        self.totalPoints = 0
        self.createdAt = Date() // Placeholder
        self.dateOfBirth = Date() // Placeholder
        self.contactNumber = "" // Placeholder
        self.dailyMinutes = 0
        self.dailyPoints = 0
        self.lastActivityDate = Date() // Placeholder
    }
    
    // MARK: - Utility Function to Parse Firestore Data and Convert to User Object
    static func fromFirestoreData(_ data: [String: Any]) -> User? {
        return User(data: data)
    }
}

struct Game {
    let name: String
    let description: String
    let points: String
    let photo: String
    let time: String
}

// GameSession class for user sessions
class GameSession {
    var sessionId: String
    var startTime: Date
    var endTime: Date
    var minutesPlayed: Int16
    var pointsEarned: Int16
    var userId: String

    init(sessionId: String, startTime: Date, endTime: Date, minutesPlayed: Int16, pointsEarned: Int16, userId: String) {
        self.sessionId = sessionId
        self.startTime = startTime
        self.endTime = endTime
        self.minutesPlayed = minutesPlayed
        self.pointsEarned = pointsEarned
        self.userId = userId
    }

    // Convenience initializer to convert Firestore document to GameSession model
    convenience init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        guard let sessionId = data["sessionId"] as? String,
              let startTimeTimestamp = data["startTime"] as? Timestamp,
              let endTimeTimestamp = data["endTime"] as? Timestamp,
              let minutesPlayed = data["minutesPlayed"] as? Int16,
              let pointsEarned = data["pointsEarned"] as? Int16,
              let userId = data["userId"] as? String else {
            return nil
        }
        
        self.init(sessionId: sessionId,
                  startTime: startTimeTimestamp.dateValue(),
                  endTime: endTimeTimestamp.dateValue(),
                  minutesPlayed: minutesPlayed,
                  pointsEarned: pointsEarned,
                  userId: userId)
    }
}

// Community and CommunityMembership models can be similarly adjusted to match Firestore documents
class Community {
    var communityId: String
    var communityName: String
    var descriptionText: String
    var createdBy: String
    var createdAt: Date
    var members: [User] = []

    init(communityId: String, communityName: String, descriptionText: String, createdBy: String, createdAt: Date) {
        self.communityId = communityId
        self.communityName = communityName
        self.descriptionText = descriptionText
        self.createdBy = createdBy
        self.createdAt = createdAt
    }

    convenience init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
            print("No data found for document: \(document.documentID)")
            return nil
        }

        // Logging document data for debugging
        print("Document Data: \(data)")

        guard let communityId = data["communityId"] as? String,
              let communityName = data["communityName"] as? String,
              let createdBy = data["createdBy"] as? String,
              let createdAtTimestamp = data["createdAt"] as? Timestamp else {
            print("Missing required fields or wrong data types in document \(document.documentID)")
            return nil
        }

        // Handling optional descriptionText field with default value if missing
        let descriptionText = data["descriptionText"] as? String ?? ""

        self.init(communityId: communityId,
                  communityName: communityName,
                  descriptionText: descriptionText,
                  createdBy: createdBy,
                  createdAt: createdAtTimestamp.dateValue())
    }
}

class CommunityMembership {
    var membershipId: String
    var userId: String
    var communityId: String
    var joinedAt: Date

    init(membershipId: String, userId: String, communityId: String, joinedAt: Date) {
        self.membershipId = membershipId
        self.userId = userId
        self.communityId = communityId
        self.joinedAt = joinedAt
    }

    convenience init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        guard let membershipId = data["membershipId"] as? String,
              let userId = data["userId"] as? String,
              let communityId = data["communityId"] as? String,
              let joinedAtTimestamp = data["joinedAt"] as? Timestamp else {
            return nil
        }
        
        self.init(membershipId: membershipId,
                  userId: userId,
                  communityId: communityId,
                  joinedAt: joinedAtTimestamp.dateValue())
    }
}
