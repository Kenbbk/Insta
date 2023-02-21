//
//  AuthService.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/01/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore



struct AuthCrendentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    
    static func logUserIn(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(withCredential credentials: AuthCrendentials, completion: @escaping(Error?) -> Void) {
        
        ImageUploader.uploadImage(image: credentials.profileImage) { imageUrl in
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { result, error in
                if let error = error {
                    print("DEBUG: Failed to register user \(error.localizedDescription)")
                    return
                }
                
                guard let uid = result?.user.uid else { return }
                
                let data: [String: Any] = ["email": credentials.email, "fullname": credentials.fullname, "profileImageUrl": imageUrl, "uid": uid, "username": credentials.username]
                
                COLLECTION_USERS.document(uid).setData(data, completion: completion)
            }
        }
    }
    
    static func resetPassword(withEmail email: String, completion: @escaping(FirestoreCompletion)) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
}
