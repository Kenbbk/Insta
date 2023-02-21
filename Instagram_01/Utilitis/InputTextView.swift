//
//  InputTextView.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/01/30.
//

import UIKit

class InputTextView: UITextView {
    
    //MARK: - Properties

    var placeholderText: String? {
        didSet {
            placeholderlabel.text = placeholderText
        }
    }
    
    let placeholderlabel: UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    var placeholderShouldCenter = true {
        didSet {
            if placeholderShouldCenter {
                placeholderlabel.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 8)
                placeholderlabel.center(inView: self)
            } else {
                placeholderlabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 6, paddingLeft: 8)
            }
        }
    }
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholderlabel)
        placeholderlabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 6, paddingLeft: 8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Actions
    
    @objc func handleTextDidChange() {
        placeholderlabel.isHidden = !text.isEmpty
    }
    
    //MARK: - Helpers
}
