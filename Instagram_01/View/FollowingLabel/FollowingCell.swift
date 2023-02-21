//
//  FollowingCell.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/02/20.
//

import UIKit
protocol FollowingCellDelegate: class {
    func cell(_ cell: FollowingCell, FollowButtonTapped user: User)
}

class FollowingCell: UITableViewCell {
    
    //MARK: - Properties
    var viewModel: FollowingCellViewModel? {
        didSet {
            configure()
        }

    }
    
    weak var delegate: FollowingCellDelegate?
    private let profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.image = UIImage(named: "venom-7")
        return iv
    }()
    
    private let usernameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "venom"
        return label
    }()
    
    private let fullnameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Eddie Brock"
        label.textColor = .lightGray
        
        return label
    }()
    
    private lazy var followStatusButton: UIButton = {
        let button = UIButton()
        button.setTitle("Following", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.backgroundColor = .lightGray.withAlphaComponent(0.2)
        button.addTarget(self, action: #selector(handleRemoveButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 9
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 55, width: 55)
        profileImageView.layer.cornerRadius = 55 / 2
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        let stack = UIStackView(arrangedSubviews: [usernameLabel, fullnameLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        
        addSubview(stack)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
        
        contentView.addSubview(followStatusButton)
        followStatusButton.centerY(inView: self)
        followStatusButton.anchor(right: rightAnchor, paddingRight: 12, width: 80, height: 35)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    @objc func handleRemoveButtonTapped() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, FollowButtonTapped: viewModel.user)
    }
    
    //MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        usernameLabel.text = viewModel.username
        fullnameLabel.text = viewModel.fullname
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        followStatusButton.setTitle(viewModel.followingStatusButtonTitle, for: .normal)
        followStatusButton.setTitleColor(viewModel.textColor, for: .normal)
        followStatusButton.backgroundColor = viewModel.backgroundColor
    }
}
