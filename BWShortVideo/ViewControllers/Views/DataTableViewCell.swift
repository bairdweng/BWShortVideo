//
//  DataTableViewCell.swift
//  BWShortVideo
//
//  Created by bairdweng on 2020/9/24.
//

import UIKit

class DataTableViewCell: UITableViewCell {
    lazy var playerView: BWAVPlayerView = {
        let player = BWAVPlayerView()
        return player
    }()

    var videUrl: String! {
        didSet {
            playerView.playerUrl = videUrl
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // init
        contentView.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
