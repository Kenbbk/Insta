//
//  AccountNoFollowBackController.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/02/21.
//

import UIKit

private let headerIdentifier = "header"
private let followerIdentifier = "followerCell"

class AccountNoFollowBackController: UIViewController {
    
    
    //MARK: - Properties
    
    private var users = [User]()
    
    init(users: [User]) {
        self.users = users
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        return tableView
    }()
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    //MARK: - Actions
    
    //MARK: - Helpers
    
    func configureUI() {
        title = "Accounts You Don't Follow Back"
        navigationItem.backButtonDisplayMode = .minimal
        
        view.addSubview(tableView)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = 64
        tableView.delegate = self
        tableView.dataSource = self
        tableView.fillSuperview()
        tableView.backgroundColor = .white
        tableView.register(AccountNoFollowBackHeader.self, forHeaderFooterViewReuseIdentifier: headerIdentifier)
        tableView.register(FollowerCell.self, forCellReuseIdentifier: followerIdentifier)
        tableView.separatorStyle = .none
    }
}

extension AccountNoFollowBackController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        print("working")
    }
    
    func cell(_ cell: FollowerCell, followButtonTappedFor user: User) {
        print("working well")
    }
    
    
}
