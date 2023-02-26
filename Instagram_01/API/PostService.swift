//
//  PostService.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/01/30.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

struct PostService {
    
    static func uploadPost(caption: String, image: UIImage, user: User, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ImageUploader.uploadImage(image: image) { imageUrl in
            let data = ["caption": caption, "timestamp": Timestamp(date: Date()), "likes": 0, "imageUrl": imageUrl, "ownerUid": uid, "ownerImageUrl": user.profileImageUrl, "ownerUsername": user.username] as [String : Any]
            
            let docRef = COLLECTION_POSTS.document()
            docRef.setData(data, completion: completion)
            
            updateUserFeedAfterPost(postid: docRef.documentID)
        }
    }
    
    static func fetchPosts(completion: @escaping(([Post]) -> Void)) {
        COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map({ Post(postID: $0.documentID, dictionary: $0.data()) })
            
            completion(posts)
        }
    }
    
    static func fetchPosts(forUser uid: String, completion: @escaping ([Post]) -> Void) {
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
        
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            var posts = documents.map({ Post(postID: $0.documentID, dictionary: $0.data()) })
            posts.sort {
                $0.timestamp.seconds > $1.timestamp.seconds
            }
            
            completion(posts)
            
        }
    }
    
    static func fetchPost(withPostId postid: String, completion: @escaping(Post) -> Void) {
        COLLECTION_POSTS.document(postid).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let data = snapshot.data() else { return }
            let post = Post(postID: snapshot.documentID, dictionary: data)
            completion(post)
        }
    }
    
    static func likePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_POSTS.document(post.postID).updateData(["likes": post.likes + 1])
        
        COLLECTION_POSTS.document(post.postID).collection("post-likes").document(uid).setData([:]) { _ in
            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postID).setData([:], completion: completion)
        }
    }
    
    static func unlikePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard post.likes > 0 else { return }
        
        COLLECTION_POSTS.document(post.postID).updateData(["likes": post.likes - 1])
        
        COLLECTION_POSTS.document(post.postID).collection("post-likes").document(uid).delete { _ in
            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postID).delete(completion: completion)
        }
    }
    
    static func checkIfUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).collection("user-likes").document(post.postID).getDocument { snapshot, _ in
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
        }
    }
    static func fetchFeedPost(completion: @escaping( ([Post]) -> Void) ) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        var posts = [Post]()
        
        COLLECTION_USERS.document(currentUserUid).collection("user-feed").getDocuments { snapshot, error in
            snapshot?.documents.forEach({ document in
                fetchPost(withPostId: document.documentID) { post in
                    
                    posts.append(post)
                    
                    posts.sort {
                        $0.timestamp.seconds > $1.timestamp.seconds
                    }
                    completion(posts)
                }
            })
            
        }
        
    }
    static func updateUserFeedAfterRemoving(user: User) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: currentUserUid)
        
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            let docIDs = documents.map( { $0.documentID })
            
            docIDs.forEach { id in
                COLLECTION_USERS.document(user.uid).collection("user-feed").document(id).delete()
                
            }
        }
    }
    
    static func updateUserFeedAfterForFollowing(user: User, didFollow: Bool) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: user.uid)
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            let docIDs = documents.map( { $0.documentID })
            
            docIDs.forEach { id in
                if didFollow {
                    COLLECTION_USERS.document(currentUserUid).collection("user-feed").document(id).setData([:])
                } else {
                    COLLECTION_USERS.document(currentUserUid).collection("user-feed").document(id).delete()
                }
            }
        }
    }
    
    static func updateUserFeedAfterForFollowing(uid: String, didFollow: Bool) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            let docIDs = documents.map( { $0.documentID })
            
            docIDs.forEach { id in
                if didFollow {
                    COLLECTION_USERS.document(currentUserUid).collection("user-feed").document(id).setData([:])
                } else {
                    COLLECTION_USERS.document(currentUserUid).collection("user-feed").document(id).delete()
                }
            }
        }
    }
    
    private static func updateUserFeedAfterPost(postid: String) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWERS.document(currentUserUid).collection("user-followers").getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else { return }
            
            documents.forEach { document in
                COLLECTION_USERS.document(document.documentID).collection("user-feed").document(postid).setData([:]) // each follower will get this post on their user-feed
            }
            COLLECTION_USERS.document(currentUserUid).collection("user-feed").document(postid).setData([:]) // current user will get this post on their user-feed
        }
    }
}
