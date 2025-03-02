import Foundation
import CloudKit
import Combine

enum CloudKitError: Error {
    case recordFailure
    case recordIDFailure
    case castFailure
    case cloudKitUnavailable
}

class CloudKitManager {
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private var subscriptionID = "teams-changes-subscription"
    
    // For notifying subscribers when remote changes occur
    let teamsDidChangePublisher = PassthroughSubject<Void, Never>()
    
    private init() {
        container = CKContainer.default()
        privateDatabase = container.privateCloudDatabase
        
        // Register for remote notifications
        subscribeToCloudKitNotifications()
        setupCloudKitSubscriptions()
    }
    
    // MARK: - Teams Management
    
    func saveTeams(_ teams: [SavedTeam], completion: @escaping (Result<Void, Error>) -> Void) {
        // Use a consistent record ID for teams
        let recordID = CKRecord.ID(recordName: "userTeams")
        let teamsRecord = CKRecord(recordType: "Teams", recordID: recordID)
        
        do {
            let teamsData = try JSONEncoder().encode(teams)
            teamsRecord["teamsData"] = teamsData as CKRecordValue
            
            // Save to CloudKit
            privateDatabase.save(teamsRecord) { (record, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchTeams(completion: @escaping (Result<[SavedTeam], Error>) -> Void) {
        // Use a consistent record ID for teams
        let recordID = CKRecord.ID(recordName: "userTeams")
        
        privateDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                // Check if record not found (this is normal for first-time users)
                let ckError = error as? CKError
                if ckError?.code == .unknownItem {
                    // Return empty array for new users
                    completion(.success([]))
                    return
                }
                
                completion(.failure(error))
                return
            }
            
            guard let record = record else {
                completion(.failure(CloudKitError.recordFailure))
                return
            }
            
            guard let teamsData = record["teamsData"] as? Data else {
                completion(.failure(CloudKitError.castFailure))
                return
            }
            
            do {
                let teams = try JSONDecoder().decode([SavedTeam].self, from: teamsData)
                completion(.success(teams))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Check iCloud availability
    func checkCloudKitAvailability(completion: @escaping (Bool) -> Void) {
        container.accountStatus { (status, error) in
            switch status {
            case .available:
                completion(true)
            default:
                completion(false)
            }
        }
    }
    
    // MARK: - CloudKit Subscriptions
    
    private func setupCloudKitSubscriptions() {
        // Check if subscription already exists
        let predicate = NSPredicate(format: "recordType = %@", "Teams")
        let subscription = CKQuerySubscription(recordType: "Teams", 
                                              predicate: predicate,
                                              subscriptionID: subscriptionID,
                                              options: [.firesOnRecordUpdate, .firesOnRecordCreation])
        
        // Configure notification
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true // For silent notifications
        subscription.notificationInfo = notificationInfo
        
        // Save subscription
        privateDatabase.save(subscription) { _, error in
            if let error = error {
                if let ckError = error as? CKError, 
                   ckError.code == .serverRejectedRequest,
                   error.localizedDescription.contains("already exists") {
                    // Subscription already exists, which is fine
                    return
                }
                print("Error setting up CloudKit subscription: \(error.localizedDescription)")
            }
        }
    }
    
    // Process CloudKit notifications
    func handleRemoteNotification(userInfo: [AnyHashable: Any]) {
        // Check if this is a CloudKit notification
        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        
        // Verify it's a subscription notification
        guard cloudKitNotification?.subscriptionID == subscriptionID,
              cloudKitNotification?.notificationType == .query else {
            return
        }
        
        // Notify subscribers about the change
        DispatchQueue.main.async {
            self.teamsDidChangePublisher.send()
        }
    }
    
    // Register app to receive CloudKit push notifications
    private func subscribeToCloudKitNotifications() {
        // This will be handled by the AppDelegate or SceneDelegate
    }
}