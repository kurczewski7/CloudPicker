//
//  ViewController.swift
//  CloudPicker
//
//  Created by Slawek Kurczewski on 25/02/2020.
//  Copyright © 2020 Slawomir Kurczewski. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CloudPickerDeleate {
    var documents = [CloudPicker.Document]()
    var cloudPicker: CloudPicker!
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    func documentsPicked(documents: [CloudPicker.Document]?) {
        print("documentsPicked:\(String(describing: documents))")
        documents?.forEach({ (elem) in
            self.documents.append(elem)
        })
        print("XXX:\(String(describing: documents))")
    }
    @IBAction func addFiles(_ sender: UIBarButtonItem) {
        cloudPicker.present(from: view)
        tableView.reloadData()
    }
    @IBAction func refreshAction(_ sender: UIBarButtonItem) {
          tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        documents = []
        tableView.delegate = self
        cloudPicker = CloudPicker(presentationController: self)
        cloudPicker.delegate = self
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor =  UIColor.orange        //UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl .attributedTitle = NSAttributedString(string: "Proszę czekać...odświeżanie", attributes: .none)
    }
    @objc private func refreshData(_ sender: Any) {
        print("Refresh Data")
        DispatchQueue.main.async {  self.tableView.reloadData()   }
        self.refreshControl.endRefreshing()
    }
}
extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DocumentCell
        
        cell.textLabel?.text = "\(indexPath.row+1):  \(documents[indexPath.row].fileURL.lastPathComponent)"
        cell.detailTextLabel?.text = "\(documents[indexPath.row].fileURL)"
        cell.configure(document: documents[indexPath.row])
        return cell
    }
}

