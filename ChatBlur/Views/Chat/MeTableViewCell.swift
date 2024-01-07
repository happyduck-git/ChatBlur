//
//  MeTableViewCell.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/6/24.
//

import UIKit
import FlexLayout
import PinLayout
import Supabase
import Nuke

final class MeTableViewCell: UITableViewCell {
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemMint.withAlphaComponent(0.6)
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: AppFont.normal)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.flex
            .direction(.column)
            .alignItems(.end)
            .padding(10, 40, 10, 10)
            .define { flex in
                flex.addItem(bubbleView)
            }
        bubbleView.flex
            .alignItems(.center)
            .padding(10, 10, 10, 10)
            .define { flex in
                flex.addItem(messageLabel)
            }
        
        contentView.flex.layout(mode: .adjustHeight)

    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)
        layoutSubviews()
        return contentView.frame.size
    }
}

extension MeTableViewCell {
    
    func configure(with chat: ChatMessage) {
        self.messageLabel.text = chat.message
    }
    
}

@available(iOS 17, *)
#Preview(traits: .defaultLayout, body: {
    FriendTableViewCell()
})
