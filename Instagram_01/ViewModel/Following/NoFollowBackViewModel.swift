
//  RecommandCell.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/02/08.


import UIKit

struct NoFollowBackViewModel {

    private let user: User
    
    private let numberOfFollowersIDontFollowBack: Int

    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }

    var upperLabel: String {
        return "Account You Don't Follow Back"
    }
    
    var lowerLabel: String {
        if numberOfFollowersIDontFollowBack == 1 {
            return "\(user.username)"
        } else {
            return "\(user.username) and \(numberOfFollowersIDontFollowBack - 1) others"
        }
    }
//    var text: NSAttributedString {
//        let attributedText = NSMutableAttributedString(string: "Account You Don't Follow Back", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
//        attributedText.append(NSAttributedString(string: "\(user.username) and 20 others"))
//        return attributedText
//    }

    init(user: User, number: Int) {
        self.user = user
        self.numberOfFollowersIDontFollowBack = number

    }
    
    
}
