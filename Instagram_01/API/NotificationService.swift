//
//  NotificationService.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/02/05.
//

import FirebaseFirestore
import FirebaseAuth

struct NotificationService {
    
    static func uploadNotification(toUid uid: String, fromUser: User, type: NotificationType, post: Post? = nil) {
        guard let currenUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currenUid else { return }
        
        let docRef = COLLECTION_NOTIFICATION.document(uid).collection("user-notifications").document()
        
        var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                   "uid": fromUser.uid,
                                   "type": type.rawValue,
                                   "id": docRef.documentID,
                                   "userProfileImageUrl": fromUser.profileImageUrl,
                                   "username": fromUser.username]
        if let post = post {
            data["postId"] = post.postID
            data["postImageUrl"] = post.imageUrl
        }
        
        docRef.setData(data)
    }
    
    static func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_NOTIFICATION.document(uid).collection("user-notifications").order(by: "timestamp", descending: true)
        
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            let notofications = documents.map { Notification(dictionary: $0.data())}
            completion(notofications)
        }
    }
}
