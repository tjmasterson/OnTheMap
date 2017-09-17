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

    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(rawValue: "RefreshPeopleData"), object: nil)
    }
    
    func refresh() {
        showLoading()
        self.tableView.reloadData()
        hideLoading()
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
            Helper.handleError("No media url for this person", viewController: self)
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

extension ListPeopleViewController {
    func showLoading() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.blue
        view.alpha = CGFloat(0.5)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        view.alpha = CGFloat(1.0)
        activityIndicator.stopAnimating()
    }
    
}
