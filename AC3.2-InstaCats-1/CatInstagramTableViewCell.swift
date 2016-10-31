//
//  CatInstagramTableViewCell.swift
//  AC3.2-InstaCats-1
//
//  Created by Amber Spadafora on 10/30/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

class CatInstagramTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var iGPhoto: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iGPhoto.layer.cornerRadius = 35
        iGPhoto.layer.masksToBounds = true
        // Initialization code
    }
    
    func setData(instaCats: InstaCat){
        iGPhoto.image = UIImage(named: instaCats.name)
        userName.text = instaCats.name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
