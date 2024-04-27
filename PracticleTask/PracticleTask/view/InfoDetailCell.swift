//
//  InfoDetailCell.swift
//  PracticleTask
//
//  Created by krina kalariya on 26/04/24.
//

import UIKit

class InfoDetailCell: UITableViewCell {

    static let id = "InfoDetailCell"
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var userIdLbl: UILabel!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bodyLbl: UILabel!
    
    var data : UserDetailModel? {
        didSet {
            self.userIdLbl.text = "\(data?.userID ?? 0)"
            self.idLbl.text = "\(data?.id ?? 0)"
            self.titleLbl.text = "\(data?.title ?? "")"
            self.bodyLbl.text = "\(data?.body ?? "")"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgView.layer.cornerRadius = 6
        self.bgView.layer.masksToBounds = true
        self.bgView.addDropShadow()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
