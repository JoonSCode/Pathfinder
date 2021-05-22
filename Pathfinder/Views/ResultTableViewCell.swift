//
//  ResultTableViewCell.swift
//  Pathfinder
//
//  Created by 윤준수 on 2021/05/22.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    @IBOutlet var placeName: UILabel!
    @IBOutlet var placeDistance: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
