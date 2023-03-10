//
//  ProfileController.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/01/19.
//

import UIKit
import FirebaseAuth

private let cellIdentifier = "ProfileCell"

private let headerIdentifier = "ProfileHeader"

class ProfileController: UICollectionViewController {
    
    //MARK: - Properties
    
    private var ownerUser: User
    private var posts = [Post]()
    
    //MARK: - Lifecycle
    
    init(user: User) {
        self.ownerUser = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        checkIfUserIsFollowed()
        fetchPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchUserStats()
        print("View appeared")
    }
    
    //MARK: - API
    
    func checkIfUserIsFollowed() {
        UserService.checkIfUserIsFollowed(uid: ownerUser.uid) { isFollowed in
            self.ownerUser.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStats() {
        UserService.fetchUserStats(uid: ownerUser.uid) { stats in
            self.ownerUser.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    func fetchPosts() {
        PostService.fetchPosts(forUser: ownerUser.uid) { posts in
            self.posts = posts
            self.collectionView.reloadData()
            
        }
    }
    
    //MARK: - Helpers
    func toggleFollowButton(uid: String) {
        guard ownerUser.uid != Auth.auth().currentUser?.uid else { return }
        guard ownerUser.uid == uid else { return }
        
        ownerUser.isFollowed.toggle()
        fetchUserStats()
    }
    
    func configureCollectionView() {
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .white
        navigationItem.title = ownerUser.username
        collectionView.backgroundColor = .white
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.alwaysBounceVertical = true
    }
}

//MARK: - UICollectionViewDataSource

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ProfileCell
        cell.viewModel = PostViewModel(post: posts[indexPath.row])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        
        header.backgroundColor = .white
        header.delegate = self
        
        header.viewModel = ProfileHeaderViewModel(user: ownerUser)
        
        return header
    }
}

//MARK: - UICollectionViewDelegate

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.post = posts[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
        
    }
}
//MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 240)
    }
}

extension ProfileController: ProfileHeaderDelegate {
    
    func header(_ profileHeader: ProfileHeader, didTapFollowingLabelFor user: User) {
        let controller = FollowerController(user: user)
        controller.isFollowerTab = false
        navigationController?.pushViewController(controller, animated: true)
    }
    func header(_ profileHeader: ProfileHeader, didTapFollowerLabelFor user: User) {
        let controller = FollowerController(user: user)
        controller.isFollowerTab = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func header(_ profileHeader: ProfileHeader, didtapActionButtonFor user: User) {
        guard let tab = self.tabBarController as? MainTabController else { return }
        
        guard let currentUser = tab.user else { return }
        
        
        if user.isCurrentUser {
            
        } else if user.isFollowed {
            
            UserService.unfollow(uid: user.uid) { error in
                
                self.fetchUserStats()
                Helper.syncFollowerWithOtherViews(uid: user.uid)
                
                PostService.updateUserFeedAfterForFollowing(user: user, didFollow: false)
            }
        } else {
            UserService.follow(uid: user.uid) { error in
                
                self.fetchUserStats()
                Helper.syncFollowerWithOtherViews(uid: user.uid)
                
                NotificationService.uploadNotification(toUid: user.uid, fromUser: currentUser, type: .follow)
                PostService.updateUserFeedAfterForFollowing(user: user, didFollow: true)
            }
        }
    }
}



