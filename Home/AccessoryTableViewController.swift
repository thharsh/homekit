//
//  AccessoryTableViewController.swift
//  Home
//
//  Created by Harsh on 17/06/20.
//  Copyright © 2020 Harsh. All rights reserved.
//

import UIKit
import HomeKit

class AccessoryTableViewController: UITableViewController {

    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    var accessories: [HMAccessory] = []
    var home: HMHome?
    
    // For discovering new accessories
    let browser = HMAccessoryBrowser()
    var discoveredAccessories: [HMAccessory] = []
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      title = "\(home?.name ?? "") Accessories"
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(discoverAccessories(sender:)))
      
      loadAccessories()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return accessories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myAcell", for: indexPath) as! AccessoryTableViewCell
        cell.accessory = accessories[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let accessory = accessories[indexPath.row]
        
        guard let characteristic = accessory.find(serviceType: HMServiceTypeLightbulb, characteristicType: HMCharacteristicMetadataFormatBool) else {
          return
        }
        
        let toggleState = (characteristic.value as! Bool) ? false : true
        characteristic.writeValue(NSNumber(value: toggleState)) { error in
          if error != nil {
            print("Something went wrong when attempting to update the service characteristic.")
          }
          tableView.reloadData()
        }
    }

   private func loadAccessories() {
      guard let homeAccessories = home?.accessories else {
         return
    }
    
    for accessory in homeAccessories {
      if let characteristic = accessory.find(serviceType: HMServiceTypeLightbulb, characteristicType: HMCharacteristicMetadataFormatBool) {
        accessories.append(accessory)
        accessory.delegate = self
        characteristic.enableNotification(true) { error in
          if error != nil {
            print("Something went wrong when enabling notification for a chracteristic.")
          }
        }
      }
    }
    
    tableView?.reloadData()
  }
  
  @objc func discoverAccessories(sender: UIBarButtonItem) {
    activityIndicator.startAnimating()
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    
    discoveredAccessories.removeAll()
    browser.delegate = self
    browser.startSearchingForNewAccessories()
    perform(#selector(stopDiscoveringAccessories), with: nil, afterDelay: 10)
  }
  
  @objc private func stopDiscoveringAccessories() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(discoverAccessories(sender:)))
    if discoveredAccessories.isEmpty {
      let alert = UIAlertController(title: "No Accessories Found",
                                    message: "No Accessories were found. Make sure your accessory is nearby and on the same network.",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
    } else {
      let homeName = home?.name
      let message = """
                    Found a total of \(discoveredAccessories.count) accessories. \
                    Add them to your home \(homeName ?? "")?
                    """
      
      let alert = UIAlertController(
        title: "Accessories Found",
        message: message,
        preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Cancel", style: .default))
      alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
        self.addAccessories(self.discoveredAccessories)
      })
      present(alert, animated: true)
    }
  }
  
  private func addAccessories(_ accessories: [HMAccessory]) {
    for accessory in accessories {
      home?.addAccessory(accessory) { [weak self] error in
        guard let self = self else {
          return
        }
        if let error = error {
          print("Failed to add accessory to home: \(error.localizedDescription)")
        } else {
          self.loadAccessories()
        }
      }
    }
  }
}

extension AccessoryTableViewController : HMAccessoryDelegate {
  func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
    tableView?.reloadData()
  }
}

extension AccessoryTableViewController : HMAccessoryBrowserDelegate {
  func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
    discoveredAccessories.append(accessory)
  }
}

extension HMAccessory {
  func find(serviceType: String, characteristicType: String) -> HMCharacteristic? {
    return services.lazy
      .filter { $0.serviceType == serviceType }
      .flatMap { $0.characteristics }
      .first { $0.metadata?.format == characteristicType }
  }
}


