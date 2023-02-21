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
    
    
    
    static func fetchFollowersIDontFollowBack(for uid: String, completion: @escaping ([User]) -> Void) {
        var Follower = [String]()
        var following = [String]()
        var users = [User]()
        
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                completion(users) // users 는 [] 으로 마무리
                return
            }
            Follower = documents.map( { $0.documentID}) // Follower 찾아옴 follower가 아무도 없으면 밑에 모든 것들이 무용지물
            
            COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    following = documents.map( { $0.documentID }) // document 값이 있으면 그것을 바탕으로 Following 업데이트
                }
                
                let resultArray = Array(Set(Follower).subtracting(Set(following))) // 나를 팔로우 하지만 나는 팔로우백 하지 않는 사람들 어레이를 만듬
                
                resultArray.forEach { userUid in
                    COLLECTION_USERS.document(userUid).getDocument { snapshot, error in
                        guard let dictionary = snapshot?.data() else { return }
                        let user = User(dictionary: dictionary)
                        users.append(user)
                        completion(users)
                    }
                }
            }
        }
    }
    
    static func fetchOneUserAndCount(for uid: String, completion: @escaping (User?, Int) -> Void) {
        var Follower = [String]()
        var following = [String]()
        var user: User?
        var numberOfFollwerWhoIDoNotFollowBack: Int = 0
        
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                completion(user, numberOfFollwerWhoIDoNotFollowBack) // users 는 [] 으로 마무리
                return
            }
            Follower = documents.map( { $0.documentID}) // Follower 찾아옴 follower가 아무도 없으면 밑에 모든 것들이 무용지물
            
            COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    following = documents.map( { $0.documentID }) // document 값이 있으면 그것을 바탕으로 Following 업데이트
                }
                
                let resultArray = Array(Set(Follower).subtracting(Set(following))) // 나를 팔로우 하지만 나는 팔로우백 하지 않는 사람들 어레이를 만듬
                
                if resultArray.count == 0 {
                    completion(user,numberOfFollwerWhoIDoNotFollowBack)
                    return
                }
                
                numberOfFollwerWhoIDoNotFollowBack = resultArray.count
                
                guard let randomUserUid = resultArray.randomElement() else { return }
                COLLECTION_USERS.document(randomUserUid).getDocument { snapshot, error in
                    guard let dictionary = snapshot?.data() else { return }
                    user = User(dictionary: dictionary)
                    completion(user, numberOfFollwerWhoIDoNotFollowBack)
                }
                
                
                
            }
        }
    }
}

