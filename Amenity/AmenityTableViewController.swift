//
//  FilterAmenityViewController.swift
//  Amenity
//
//  Created by Alan Zhang on 2020-04-06.
//  Copyright © 2020 Alan Zhang. All rights reserved.
//

import UIKit
import MapKit

class AmenityTableViewController: UITableViewController {
    
    private var amenities: [(MKAnnotation, String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Nearby Amenities"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(filterTapped))
        
        tableView.register(AmenityCell.self, forCellReuseIdentifier: "AmenityCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func filterTapped() {
        // TODO: filter amenities
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return amenities.count
    }
    
    func appendAmenity(annotation: MKAnnotation, address: String) {
        self.amenities.append((annotation, address))
        self.tableView.insertRows(at: [IndexPath(row: self.amenities.count - 1, section: 0)], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AmenityCell", for: indexPath)

        let rowIndex = indexPath.row
        let annotation = amenities[rowIndex].0
        let address = amenities[rowIndex].1
        
        cell.textLabel?.text = annotation.title ?? ""
        cell.textLabel?.textColor = .label
        cell.detailTextLabel?.text = address
        cell.detailTextLabel?.textColor = .label

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class AmenityCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
