//
//  ListPeopleViewController.swift
//  OnTheMap
//
//  Created by Taylor Masterson on 8/21/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit

class ListPeopleTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
}

class ListPeopleViewController: UIViewController {

//    var people: [OTMPerson] = [OTMPerson]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPeople()
    }
    
    func fetchPeople() {
        OTMClient.sharedInstance().getPeople() { (people, error) in
            if let _ = people {
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func refresh() {
        print("hey from list")
//        fetchPeople()
    }

}

extension ListPeopleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OTMData.shared.people.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = OTMData.shared.people[indexPath.row]
        if let mediaURL = URL(string: person.mediaURL) {
            let app = UIApplication.shared
            app.open(mediaURL, completionHandler: nil)
        } else {
            print("no media url for this person")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "ListPeopleTableViewCell"
        let person = OTMData.shared.people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ListPeopleTableViewCell
        cell.nameLabel.text = "\(person.firstName) \(person.lastName)"
        return cell
    }
}
