//
//  SingleLabelTableViewCell.swift
//  Home
//
//  Created by Harsh on 17/06/20.
//  Copyright © 2020 Harsh. All rights reserved.
//

import UIKit
import HomeKit

class SingleLabelTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var label: UILabel!
    
    var home: HMHome? {
      didSet {
        if let home = home {
          label.text = home.name
        }
      }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
