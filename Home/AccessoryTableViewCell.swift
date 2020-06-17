//
//  AccessoryTableViewCell.swift
//  Home
//
//  Created by Harsh on 17/06/20.
//  Copyright © 2020 Harsh. All rights reserved.
//

import UIKit
import HomeKit

class AccessoryTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var stateView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var accessory: HMAccessory? {
      didSet {
        if let accessory = accessory {
          label.text = accessory.name
          
          let state = getLightbulbState(accessory)
            stateView.backgroundColor = state ? UIColor.green : UIColor.red
        }
      }
    }
    
    private func getLightbulbState(_ accessory: HMAccessory) -> Bool {
      guard let characteristic = accessory.find(serviceType: HMServiceTypeLightbulb, characteristicType: HMCharacteristicMetadataFormatBool),
        let value = characteristic.value as? Bool else {
          return false
      }
      
      return value ? true : false
    }
}
