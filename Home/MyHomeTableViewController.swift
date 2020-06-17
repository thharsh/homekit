//
//  MyHomeTableViewController.swift
//  Home
//
//  Created by Harsh on 17/06/20.
//  Copyright © 2020 Harsh. All rights reserved.
//

import UIKit
import HomeKit

class MyHomeTableViewController: UITableViewController {
    
    var homes: [HMHome] = []
    let homeManager = HMHomeManager()
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      
      homeManager.delegate = self
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      title = "Homes"
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newHome(sender:)))
      addHomes(homeManager.homes)
      tableView?.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return homes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath) as! SingleLabelTableViewCell

        // Configure the cell...
        cell.home = homes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = navigationController?.storyboard?.instantiateViewController(withIdentifier: "AccessoryViewController") as! AccessoryTableViewController
        vc.home = homes[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    
    @objc func newHome(sender: UIBarButtonItem) {
       showInputDialog { homeName, roomName in
         
         self.homeManager.addHome(withName: homeName) { [weak self] home, error in
           guard let self = self else {
             return
           }
           if let error = error {
             print("Failed to add home: \(error.localizedDescription)")
           }
           if let discoveredHome = home {
             discoveredHome.addRoom(withName: roomName) { _, error  in
               if let error = error {
                 print("Failed to add room: \(error.localizedDescription)")
               } else {
                 self.homes.append(discoveredHome)
                 self.tableView?.reloadData()
               }
             }
           }
         }
       }
     }
     
     func showInputDialog(_ handler: @escaping ((String, String) -> Void)) {
       let alertController = UIAlertController(title: "Create new Home?", message: "Enter the name of your new home and give it a Room", preferredStyle: .alert)
       
       let confirmAction = UIAlertAction(title: "Create", style: .default) { _ in
         guard let homeName = alertController.textFields?[0].text,
           let roomName = alertController.textFields?[1].text else {
             return
         }
         
         handler(homeName, roomName)
       }
       
       let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
       
       alertController.addTextField { textField in
         textField.placeholder = "Enter Home name"
       }
       alertController.addTextField { textField in
         textField.placeholder = "Enter Room name"
       }
       
       alertController.addAction(confirmAction)
       alertController.addAction(cancelAction)
       
       present(alertController, animated: true)
     }
    
    func addHomes(_ homes: [HMHome]) {
      self.homes.removeAll()
      for home in homes {
        self.homes.append(home)
      }
      tableView?.reloadData()
    }

}

extension MyHomeTableViewController : HMHomeManagerDelegate {
  func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
    addHomes(manager.homes)
  }
}
