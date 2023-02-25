//
//  FollowerController.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/02/07.
//

import UIKit
import FirebaseAuth

private let followerIdentifier = "followerCell"
private let noFollowBackIdentifier = "noFollowBackCell"
private let headerIdentifier = "header"

class FollowerController: UIViewController {
    //MARK: - Properties
    
    var isFollowerTab: Bool?
    private var pageOwnerUser: User // 지금있는 프로파일 페이지의 주인
    private var followers = [User]()
    private var filteredFollowers = [User]()
    private var followingUsers = [User]()
    private var filteredFollowingUsers = [User]()
    private var FollowersThatIdontFollowBack = [User]()
    private var pickedFollower: User?
    private var numberOfFollowerIDontFollowBack: Int = 0
    private var searchTextForFollower: String = ""
    private var searchTextForFollowing: String = ""
    
    private var inSearchModeFollower: Bool {
        return searchControllerFollower.isActive && !searchControllerFollower.searchBar.text!.isEmpty
    }
    
    private var inSearchModeFollowing: Bool {
        return searchControllerFollowing.isActive && !searchControllerFollowing.searchBar.text!.isEmpty
    }
    init(user: User) {
        
        self.pageOwnerUser = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        searchControllerFollowing.isActive = false
        searchControllerFollower.isActive = false
        print("Followercontroller deinit")
    }
    
    private lazy var followerTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var followingTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private let searchControllerFollower = UISearchController(searchResultsController: nil)
    private let searchControllerFollowing = UISearchController(searchResultsController: nil)
    
    private lazy var followerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("0 Followers", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(followerButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var FollowingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("0 Following", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(followingButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private let leftDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(1)
        return view
    }()
    
    private let rightDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.3)
        return view
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureSearchControllerFollower()
        configureSearchControllerFollowing()
        configureTableView()
        fetchUsers()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchControllerFollower.searchBar.isHidden = false
        searchControllerFollowing.searchBar.isHidden = false
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchControllerFollower.searchBar.isHidden = true
        searchControllerFollowing.searchBar.isHidden = true
    }
    
    //MARK: - Actions
    
    @objc func followingButtonTapped(_ sender: UIButton) {
        updateUIWhenButtonTapped(sender: sender)
        isFollowerTab = false
        followingTableView.isHidden = false
        followerTableView.isHidden = true
        
        searchTextForFollower = searchControllerFollower.searchBar.text!
        searchControllerFollower.isActive = false
        
        if searchTextForFollowing != "" {
            searchControllerFollowing.searchBar.text = searchTextForFollowing
            searchControllerFollowing.isActive = true
        }
    }
    @objc func followerButtonTapped(_ sender: UIButton) {
        updateUIWhenButtonTapped(sender: sender)
        isFollowerTab = true
        followingTableView.isHidden = true
        followerTableView.isHidden = false
        
        searchTextForFollowing = searchControllerFollowing.searchBar.text!
        
        searchControllerFollowing.isActive = false
        
        if searchTextForFollower != "" {
            searchControllerFollower.searchBar.text = searchTextForFollower
            searchControllerFollower.isActive = true
        }
    }
    
    //MARK: - Helpers
    func tableViewUpdateAfterFollowOrUnfollow(uid: String) {
        guard pageOwnerUser.uid == Auth.auth().currentUser?.uid else { return }
        
        if let firstIndexForFollower = followers.firstIndex(where: { $0.uid == uid }) {
            followers[firstIndexForFollower].isFollowed.toggle()
            followers[firstIndexForFollower].mustShowInFollowerController = true
            
            if let firstIndexForFilteredFollower = filteredFollowers.firstIndex(where: { $0.uid == uid}) {
                filteredFollowers[firstIndexForFilteredFollower].isFollowed.toggle()
                filteredFollowers[firstIndexForFilteredFollower].mustShowInFollowerController = true
            }
            followerTableView.reloadData()
        }
        followerTableView.reloadData()
        
        guard let firstIndexForFollowing = followingUsers.firstIndex(where: {$0.uid == uid }) else { return }
        followingUsers[firstIndexForFollowing].isFollowed.toggle()
        
        if let firstIndexForFilteredFollowing = filteredFollowingUsers.firstIndex(where: { $0.uid == uid }) {
            filteredFollowingUsers[firstIndexForFilteredFollowing].isFollowed.toggle()
        }
        followingTableView.reloadData()
    }
    
//    func FollowerUpdate(uid: String) {
//        guard pageOwnerUser.uid == Auth.auth().currentUser?.uid else { return }
//
//        guard let firstIndex = followers.firstIndex(where: { $0.uid == uid }) else { return }
//        followers[firstIndex].isFollowed.toggle()
//
//        if let firstIndexForFilter = filteredFollowers.firstIndex(where: { $0.uid == uid }) {
//            filteredFollowers[firstIndexForFilter].isFollowed.toggle()
//        }
//        followerTableView.reloadData()
//    }

    
    private func fetchUsers() {
        
        
        let group = DispatchGroup()
        group.enter()
        FollowService.fetchFollowersAndWheatherFollowed(for: pageOwnerUser.uid) { users in
            
            self.followers = users.sorted(by: { $0.username < $1.username})
            
            let followersIDontFollowBack = users.filter { user in
                !user.isFollowed
            }
            self.FollowersThatIdontFollowBack = followersIDontFollowBack
            self.numberOfFollowerIDontFollowBack = followersIDontFollowBack.count
            
            self.pickedFollower = followersIDontFollowBack.randomElement()
            
            group.leave()
        }
        
        group.enter()
        FollowService.fetchFollowing(for: pageOwnerUser.uid) { users in
            
            self.followingUsers = users.sorted(by: { $0.username < $1.username})
            group.leave()
        }
        
        group.notify(queue: .main) {
            
            self.updateFollowingAndFollowerNumber()
            self.followerTableView.reloadData()
            self.followingTableView.reloadData()
        }
    }
    
    func updateFollowingAndFollowerNumber() {
        followerButton.setTitle("\(followers.count) Followers", for: .normal)
        FollowingButton.setTitle("\(followingUsers.count) Following", for: .normal)
    }
    
    func updateUIWhenButtonTapped(sender: UIButton) {
        if sender == followerButton {
            followerButton.isUserInteractionEnabled = false
            FollowingButton.isUserInteractionEnabled = true
            rightDividerView.backgroundColor = .lightGray.withAlphaComponent(0.3)
            leftDividerView.backgroundColor = .lightGray.withAlphaComponent(1.0)
            followerButton.setTitleColor(.black, for: .normal)
            FollowingButton.setTitleColor(.lightGray, for: .normal)
            searchControllerFollowing.searchBar.isHidden = true
            searchControllerFollower.searchBar.isHidden = false
        } else {
            followerButton.isUserInteractionEnabled = true
            FollowingButton.isUserInteractionEnabled = false
            rightDividerView.backgroundColor = .lightGray.withAlphaComponent(1.0)
            leftDividerView.backgroundColor = .lightGray.withAlphaComponent(0.3)
            followerButton.setTitleColor(.lightGray, for: .normal)
            FollowingButton.setTitleColor(.black, for: .normal)
            searchControllerFollowing.searchBar.isHidden = false
            searchControllerFollower.searchBar.isHidden = true
        }
    }
    func UpdateButtonUi() {
        guard let isFollowerTab = isFollowerTab else { return }
        if isFollowerTab {
            followerButton.isUserInteractionEnabled = false
            FollowingButton.isUserInteractionEnabled = true
            rightDividerView.backgroundColor = .lightGray.withAlphaComponent(0.3)
            leftDividerView.backgroundColor = .lightGray.withAlphaComponent(1.0)
            followerButton.setTitleColor(.black, for: .normal)
            FollowingButton.setTitleColor(.lightGray, for: .normal)
            followerTableView.isHidden = false
            followingTableView.isHidden = true
            searchControllerFollowing.searchBar.isHidden = true
            searchControllerFollower.searchBar.isHidden = false
            
        } else {
            followerButton.isUserInteractionEnabled = true
            FollowingButton.isUserInteractionEnabled = false
            rightDividerView.backgroundColor = .lightGray.withAlphaComponent(1.0)
            leftDividerView.backgroundColor = .lightGray.withAlphaComponent(0.3)
            followerButton.setTitleColor(.lightGray, for: .normal)
            FollowingButton.setTitleColor(.black, for: .normal)
            followerTableView.isHidden = true
            followingTableView.isHidden = false
            searchControllerFollowing.searchBar.isHidden = false
            searchControllerFollower.searchBar.isHidden = true
        }
    }
    
    func configureSearchControllerFollower() {
        searchControllerFollower.searchResultsUpdater = self
        searchControllerFollower.obscuresBackgroundDuringPresentation = false
        searchControllerFollower.hidesNavigationBarDuringPresentation = false
        searchControllerFollower.searchBar.placeholder = "Search"
        searchControllerFollower.searchBar.autocapitalizationType = .none
        searchControllerFollower.searchBar.delegate = self
        searchControllerFollower.searchBar.backgroundImage = UIImage()
        searchControllerFollower.automaticallyShowsCancelButton = false
        
        followerTableView.tableHeaderView = searchControllerFollower.searchBar
        self.definesPresentationContext = false
    }
    
    func configureSearchControllerFollowing() {
        searchControllerFollowing.searchResultsUpdater = self
        searchControllerFollowing.obscuresBackgroundDuringPresentation = false
        searchControllerFollowing.hidesNavigationBarDuringPresentation = false
        searchControllerFollowing.searchBar.placeholder = "Search"
        searchControllerFollowing.searchBar.autocapitalizationType = .none
        searchControllerFollowing.searchBar.delegate = self
        searchControllerFollowing.searchBar.backgroundImage = UIImage()
        searchControllerFollowing.automaticallyShowsCancelButton = false
        followingTableView.tableHeaderView = searchControllerFollowing.searchBar
        self.definesPresentationContext = false
    }
    
    func configureUI() {
        navigationItem.backButtonTitle = ""
        navigationItem.title = pageOwnerUser.username
        view.backgroundColor = .white
        
        view.addSubview(followerButton)
        followerButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, width: view.frame.width / 2, height: 50)
        
        view.addSubview(FollowingButton)
        FollowingButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, width: view.frame.width / 2, height: 50)
        
        view.addSubview(leftDividerView)
        leftDividerView.anchor(top: followerButton.bottomAnchor, left: view.leftAnchor, paddingTop: 8, width: view.frame.width / 2, height: 1 )
        
        view.addSubview(rightDividerView)
        rightDividerView.anchor(top: followerButton.bottomAnchor, right: view.rightAnchor, paddingTop: 8, width: view.frame.width / 2, height: 1 )
        
        UpdateButtonUi()
    }
    func configureTableView() {
        view.addSubview(followerTableView)
        followerTableView.anchor(top: leftDividerView.bottomAnchor,left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
        followerTableView.register(FollowerCell.self, forCellReuseIdentifier: followerIdentifier)
        followerTableView.register(NoFollowBackCell.self, forCellReuseIdentifier: noFollowBackIdentifier)
        
        followerTableView.rowHeight = 64
        followerTableView.register(CustomHeader.self, forHeaderFooterViewReuseIdentifier: headerIdentifier)
        followerTableView.separatorStyle = .none
        followerTableView.tableFooterView = UIView(frame: .zero)
        followerTableView.sectionFooterHeight = 0
        followerTableView.backgroundColor = .clear
        
        view.addSubview(followingTableView)
        followingTableView.anchor(top: leftDividerView.bottomAnchor,left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
        followingTableView.register(FollowingCell.self, forCellReuseIdentifier: followerIdentifier)
        followingTableView.register(NoFollowBackCell.self, forCellReuseIdentifier: noFollowBackIdentifier)
        
        followingTableView.rowHeight = 64
        followingTableView.register(CustomHeader.self, forHeaderFooterViewReuseIdentifier: headerIdentifier)
        followingTableView.separatorStyle = .none
        followingTableView.tableFooterView = UIView(frame: .zero)
        followingTableView.sectionFooterHeight = 0
        followingTableView.backgroundColor = .clear
    }
    }

//MARK: - UITableViewDataSource
extension FollowerController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == followerTableView {
            if section == 0 {
                if inSearchModeFollower {
                    return 0
                } else {
                    return pickedFollower == nil ? 0 : 1
                }
            } else {
                return inSearchModeFollower ? filteredFollowers.count : followers.count
            }
        }
        
        else {
            return inSearchModeFollowing ? filteredFollowingUsers.count : followingUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == followerTableView {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: noFollowBackIdentifier, for: indexPath) as! NoFollowBackCell
                guard let pickedFollower = pickedFollower else { fatalError()}
                cell.viewModel = NoFollowBackViewModel(user: pickedFollower, number: FollowersThatIdontFollowBack.count)
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: followerIdentifier, for: indexPath) as! FollowerCell
                let user = inSearchModeFollower ? filteredFollowers[indexPath.row] : followers[indexPath.row]
                cell.viewModel = FollowerCellViewModel(user: user)
                cell.delegate = self
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: followerIdentifier, for: indexPath) as! FollowingCell
            let user = inSearchModeFollowing ? filteredFollowingUsers[indexPath.row] : followingUsers[indexPath.row]
            cell.viewModel = FollowingCellViewModel(user: user)
            cell.delegate = self
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == followerTableView {
            return 2
            
        } else {
            return 1
        }
    }
}
//MARK: - UITableViewDelegate
extension FollowerController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == followerTableView {
            if indexPath.section == 0 {
                
                let controller = AccountNoFollowBackController(user: pageOwnerUser)
                navigationController?.pushViewController(controller, animated: true)
            } else {
                let user = inSearchModeFollower ? filteredFollowers[indexPath.row] : followers[indexPath.row]
                let controller = ProfileController(user: user)
                navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            let user = inSearchModeFollowing ? filteredFollowingUsers[indexPath.row] : followingUsers[indexPath.row]
            let controller = ProfileController(user: user)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView == followerTableView {
            if FollowersThatIdontFollowBack.count == 0 {
                return 0
            } else {
                return inSearchModeFollower ? 0 : 50
            }
            
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as! CustomHeader
        if section == 0 {
            header.myLabel.text = "Categories"
            
        } else {
            header.myLabel.text = "All Followers"
            
        }
        return header
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        searchControllerFollower.isActive = false
        searchControllerFollower.searchBar.endEditing(true)
        
        
//        searchControllerFollowing.isActive = false
        searchControllerFollowing.searchBar.endEditing(true)
    }
}
//MARK: - CustomHeader
class CustomHeader: UITableViewHeaderFooterView {
    var myLabel: UILabel = {
        let label = UILabel()
        label.text = "All Followers"
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.backgroundColor = .white
        return label
    }()
    
    var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(myLabel)
        myLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, paddingLeft: 15, width: 140)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UISearchResultsUpdating
extension FollowerController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        if searchController == searchControllerFollower {
            guard let searchText = searchController.searchBar.text?.lowercased() else { return }
            filteredFollowers = followers.filter( { $0.username.contains(searchText) || $0.fullname.lowercased().contains(searchText)} )
            print("DEBUG: Filtered users a \(filteredFollowers)")
            followerTableView.reloadData()
            print("followerTableView reloadedData")
        }
        if searchController == searchControllerFollowing {
            guard let searchText = searchController.searchBar.text?.lowercased() else { return }
            filteredFollowingUsers = followingUsers.filter( { $0.username.contains(searchText) || $0.fullname.lowercased().contains(searchText)} )
            print("DEBUG: Filtered users b \(filteredFollowingUsers)")
            print("followingTableView reloadedData")
            followingTableView.reloadData()
        }
    }
}

//MARK: - UISearchBarDelegate
extension FollowerController: UISearchBarDelegate { }

//MARK: - FollowingCellDelegate
extension FollowerController: FollowingCellDelegate {
    
    func cell(_ cell: FollowingCell, FollowButtonTapped user: User) {
        
        if user.isFollowed == false {
            UserService.follow(uid: user.uid) { error in
                
                PostService.updateUserFeedAfterForFollowing(user: user, didFollow: true)
                Helper.getControllers(uid: user.uid)
            }
        } else {
            UserService.unfollow(uid: user.uid) { error in
                
                PostService.updateUserFeedAfterForFollowing(user: user, didFollow: false)
                Helper.getControllers(uid: user.uid)
            }
        }
        
    }
}

//MARK: - FollowerCellDelegate
extension FollowerController: FollowerCellDelegate {
    
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
                Helper.getControllers(uid: user.uid)
            }
        } else {
            
            UserService.unfollow(uid: user.uid) { error in
                
                PostService.updateUserFeedAfterForFollowing(user: user, didFollow: false)
                Helper.getControllers(uid: user.uid)
            }
        }
    }
    
    func removeFollower(user: User) {
        followers.removeAll(where: { $0.uid == user.uid})
        filteredFollowers.removeAll(where: { $0.uid == user.uid })
        followerTableView.reloadData()
        followingTableView.reloadData()
    }
    
}

