//
//  FollowService.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/02/08.
//

import Foundation

struct FollowService {
    
    static func fetchFollowing(for uid: String, completion: @escaping ([User]) -> Void) {
        COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            var users = [User]()
            
            let group = DispatchGroup()
            documents.forEach { document in
                group.enter()
                let userUid = document.documentID
                
                COLLECTION_USERS.document(userUid).getDocument { snapshot, error in
                    guard let dictionary = snapshot?.data() else { return }
                    
                    var user = User(dictionary: dictionary)
                    user.isFollowed = true
                    users.append(user)
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                completion(users)
            }
        }
    }
    
    static func fetchFollowers(for uid: String, completion: @escaping ([User]) -> Void) {
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            var users = [User]()
            documents.forEach { document in
                let userUID = document.documentID
                
                COLLECTION_USERS.document(userUID).getDocument { snapshot, error in
                    guard let dictionary = snapshot?.data() else { return }
                    
                    let user = User(dictionary: dictionary)
                    users.append(user)
                    completion(users)
                }
            }
        }
    }
    
    static func fetchFollowersAndWheatherFollowed(for uid: String, completion: @escaping ([User]) -> Void) {
        
        var follower = [String]()
        var following = [String]()
        var users = [User]()
        
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                completion(users)
                return
            }
            follower = documents.map({ $0.documentID})
            
            COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    following = documents.map( { $0.documentID })
                    
                    let intersectionArray = follower.filter { userUid in
                        following.contains(userUid)
                    }
                    
                    let group = DispatchGroup()
                    
                    follower.forEach { userUid in
                        group.enter()
                        
                        COLLECTION_USERS.document(userUid).getDocument { snapshot, error in
                            
                            guard let dictionary = snapshot?.data() else {
                                completion(users)
                                return
                            }
                            var user = User(dictionary: dictionary)
                            
                            if intersectionArray.contains(user.uid) {
                                user.isFollowed = true
                            } else {
                                user.mustShowInFollowerController = true // 팔로우 버튼이 꼭 보여야함
                            }
                            users.append(user)
                            
                            group.leave()
                        }
                    }
                    group.notify(queue: .main) {
                        
                        completion(users)
                    }
                }
            }
        }
    }
}

