//
//  TableView.swift
//  OnTheMap
//
//  Created by Peter Schorn on 6/10/20.
//  Copyright © 2020 Peter Schorn. All rights reserved.
//

import Foundation
import UIKit

class TableViewController:
    UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("table view viewWillAppear")
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    @IBAction func newPinButtonTapped(_ sender: Any) {
        let controller = self.storyboard!.instantiateViewController(
            identifier: "NewPinViewController"
        ) as! NewPinViewController
        
        controller.updateCallback =  {
            tableViewLogger.debug("reloading data from update callback")
            StudentData.sort()
            self.tableView.reloadData()
        }
        present(controller, animated: true)
    }
    
    
    @IBAction func tappedReloadButton(_ sender: Any) {
        StudentData.getStudentLocations { error in
            DispatchQueue.main.async {
                if let error = error {
                    let alert = makeAlert(
                        title: "Couldn't get student locations",
                        msg: error.localizedDescription
                    )
                    self.present(alert, animated: true)
                }
                else {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func tappedLogoutButton(_ sender: Any) {
        UdacityAPI.deleteSession { error in
            DispatchQueue.main.async {
                if let error = error {
                    let alert = makeAlert(
                        title: "Couldn't Log Out",
                        msg: error.localizedDescription
                    )
                    self.present(alert, animated: true)
                }
                else {
                    tableViewLogger.debug("will dismiss")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        tableViewLogger.debug("asked for number of rows in section")
        return StudentData.students.count
    }
    
    func tableView(
        _ tableView: UITableView, cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        tableViewLogger.debug("asked for cell \(indexPath.row)")
        
        let student = StudentData.students[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TableCell"
        ) as! TableCell
        
        cell.label.text = student.fullName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = StudentData.students[indexPath.row]
        if let url = URL(string: student.mediaURL) {
            UIApplication.shared.open(url)
        }
        else {
            tableViewLogger.warning("could not convert to URL: \(student.mediaURL)")
        }
    }
    
    
}



class TableCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!

}
