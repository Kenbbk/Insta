//
//  AccountNoFollowBackController.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/02/21.
//

import UIKit
import FirebaseAuth

private let headerIdentifier = "header"
private let followerIdentifier = "followerCell"

class AccountNoFollowBackController: UIViewController {
    
    
    //MARK: - Properties
    private var ownerUser: User // 타고 온 페이지 나중에 수정해야함 어차피 이 컨트롤러는 자기 자신의 페이지가 아니면 보이지 않아야하
    private var users = [User]() {
        didSet {
//            tableView.reloadData()
            print("Tableview Set")
        }
    }
    
    
    
    init(user: User) {
        self.ownerUser = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUsers()
        
        //        guard let controllers = navigationController?.viewControllers else { return }
        //        for item in controllers {
        //            if let yes = item as? FollowerController {
        //                yes.navigationItem.title?.append("1")
        //
        //                print("I am red")
        ////                print(yes.isFollowerTab)
        //            }
        //        }
    }
    //MARK: - Actions
    
    //MARK: - Helpers
    
    
    func fetchUsers() {
        
        FollowService.fetchFollowersAndWheatherFollowed(for: ownerUser.uid) { users in
            
            self.users = users.filter({ $0.isFollowed == false })
            self.tableView.reloadData()
            
        }
    }
    func configureUI() {
        title = "Accounts You Don't Follow Back"
        navigationItem.backButtonTitle = ""
        
        view.addSubview(tableView)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = 64
        tableView.fillSuperview()
        tableView.backgroundColor = .white
        tableView.register(AccountNoFollowBackHeader.self, forHeaderFooterViewReuseIdentifier: headerIdentifier)
        tableView.register(FollowerCell.self, forCellReuseIdentifier: followerIdentifier)
        tableView.separatorStyle = .none
    }
}

extension AccountNoFollowBackController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(users.count)
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: followerIdentifier, for: indexPath) as! FollowerCell
        let user = users[indexPath.row]
        
        cell.delegate = self
        cell.viewModel = FollowerCellViewModel(user: user)
        return cell
    }
    }

extension AccountNoFollowBackController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as! AccountNoFollowBackHeader
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - CustomHeader
class AccountNoFollowBackHeader: UITableViewHeaderFooterView {
    var myLabel: UILabel = {
        let label = UILabel()
        label.text = "These accounts follow you, but you don't follow\n them back."
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(myLabel)
        myLabel.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AccountNoFollowBackController: FollowerCellDelegate {
    func cell(_ cell: FollowerCell, wantsToUnfollow user: User) {
        UserService.removeFollow(uid: user.uid) { error in
            
            PostService.updateUserFeedAfterRemoving(user: user)
            self.removeFollower(user: user)
            print("Successfully removed")
        }
        
    }
    
    func cell(_ cell: FollowerCell, followButtonTappedFor user: User) {
        if user.isFollowed == false {
            UserService.follow(uid: user.uid) { error in
                
                PostService.updateUserFeedAfterForFollowing(user: user, didFollow: true)
                Helper.syncFollowerWithOtherViews(uid: user.uid)
            }
        } else {
            
            UserService.unfollow(uid: user.uid) { error in
                
                PostService.updateUserFeedAfterForFollowing(user: user, didFollow: false)
                Helper.syncFollowerWithOtherViews(uid: user.uid)
            }
        }
        
    }
//
//    func toggleFollowButton(user: User) {
//
//        if let firstIndex = self.users.firstIndex(where: { $0.uid == user.uid }) {
//            self.users[firstIndex].isFollowed.toggle()
//        }
//
//        //        tableView.reloadData()
//    }
    
    func toggleFollowButton(uid: String) {
        guard ownerUser.uid == Auth.auth().currentUser?.uid else { return }
        
        guard let firstIndex = users.firstIndex(where: { $0.uid == uid }) else { return }
        
        users[firstIndex].isFollowed.toggle()
        tableView.reloadData()
        print("It is toggled")
    }
    
    
    func removeFollower(user: User) {
        users.removeAll(where: { $0.uid == user.uid})
        
        tableView.reloadData()
    }
    
}
