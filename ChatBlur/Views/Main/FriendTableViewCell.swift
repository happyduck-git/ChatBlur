//
//  FriendTableViewCell.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/4/24.
//

import UIKit
import FlexLayout
import PinLayout
import Supabase
import Nuke

final class FriendTableViewCell: UITableViewCell {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemMint
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = "Username"
        label.font = .systemFont(ofSize: AppFont.normal)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.flex
            .direction(.row)
            .alignItems(.center)
            .padding(10, 30, 10)
            .define { flex in
                flex.addItem(profileImageView)
                    .width(50)
                    .height(50)
                    .marginRight(20)
                    .cornerRadius(profileImageView.frame.width / 2)
                
                flex.addItem(usernameLabel)
                    .grow(1)
            }
        
        contentView.flex.layout(mode: .adjustHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)
        layoutSubviews()
        return contentView.frame.size
    }
}

extension FriendTableViewCell {
    
    func configure(with user: ChatUser) {
        if let imageString = user.avatarUrl,
           let imageUrl = URL(string: imageString)  {
            Task {
                let image = try await ImagePipeline.shared.image(for: imageUrl)
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                }
            }
        } else {
            self.profileImageView.backgroundColor = .systemTeal
        }
        
        self.usernameLabel.text = user.username
    }
    
}

@available(iOS 17, *)
#Preview(traits: .defaultLayout, body: {
    FriendTableViewCell()
})


