//
//  Helper.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/02/24.
//

import UIKit

struct Helper {
    
    static func getController(nav: UINavigationController?, uid: String) {
        guard let controllers = nav?.viewControllers else { return }
        for controller in controllers {
            if let controller = controller as? FollowerController {
                controller.tableViewUpdateAfterFollowOrUnfollow(uid: uid)
            } else if let controller = controller as? NotificationController {
                controller.updateUIFromOtherController(uid: uid)
            } else if let controller = controller as? AccountNoFollowBackController {
                controller.toggleFollowButton(uid: uid)
                
            } else if let controller = controller as? ProfileController {
                controller.toggleFollowButton(uid: uid)
            }
        }
    }
    
    static func getControllers(uid: String) {
        let navigations = MainTabController.allNavigationControllers
        navigations.forEach { navigation in
            getController(nav: navigation, uid: uid)
        }
    }
}
