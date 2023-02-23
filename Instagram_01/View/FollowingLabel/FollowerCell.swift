//
//  DummyCell.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/02/07.
//

import UIKit

protocol FollowerCellDelegate: AnyObject {
    func cell(_ cell: FollowerCell, wantsToUnfollow user: User)
    func cell(_ cell: FollowerCell, followButtonTappedFor user: User)
}

class FollowerCell: UITableViewCell {
    //MARK: - Properties
    weak var delegate: FollowerCellDelegate?
    
    var viewModel: FollowerCellViewModel? {
        didSet {
            configure()
        }
    }
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
        label.textColor = .black.withAlphaComponent(0.7)
        
        return label
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton()
        
        button.addTarget(self, action: #selector(handleFollowButtonTapped), for: .touchUpInside)
        var attributedText = NSMutableAttributedString(string: "·", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight(30))])
        attributedText.append(NSAttributedString(string: " Follow", attributes: [.font: UIFont.boldSystemFont(ofSize: 15), .foregroundColor: UIColor.systemBlue.withAlphaComponent(0.8)]))
        button.setAttributedTitle(attributedText, for: .normal)
        button.backgroundColor = .white
        return button
    }()
    
    private lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove", for: .normal)
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
        contentView.addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        profileImageView.setDimensions(height: 55, width: 55)
        profileImageView.layer.cornerRadius = 55 / 2
        
        let stack = UIStackView(arrangedSubviews: [usernameLabel, fullnameLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        addSubview(stack)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
        
        
        contentView.addSubview(removeButton)
        removeButton.centerY(inView: self)
        removeButton.anchor(right: rightAnchor, paddingRight: 12, width: 80, height: 35)
        
        contentView.addSubview(followButton)
        followButton.centerY(inView: self)
        followButton.anchor(right: removeButton.leftAnchor, paddingRight: 50 ,width: 80, height: 35)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    @objc func handleFollowButtonTapped() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, followButtonTappedFor: viewModel.user)
        followButton.setTitle("Following", for: .normal)
        print("DEBUG: Follow Button Tapped!")
    }
    
    @objc func handleRemoveButtonTapped() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToUnfollow: viewModel.user)
        print("DEBUG: Remove Button Tapped!")
    }
    
    //MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        fullnameLabel.text = viewModel.fullname
        usernameLabel.text = viewModel.username
        followButton.isHidden = viewModel.followButtonshouldHidden
        followButton.setAttributedTitle(viewModel.followButtonTitle, for: .normal)
        
        
//        followButton.setTitle(viewModel.followButtonTitle, for: .normal)
        
    }
}


