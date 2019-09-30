//
//  PostListViewController.swift
//  Post
//
//  Created by Bethany Wride on 9/30/19.
//  Copyright © 2019 Bethany Wride. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate {
    
    let postController = PostController()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableView.automaticDimension
        
        // Set up tableView for View Controller
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        // Selector calls the function, similar to closures in Swift
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        
        postController.fetchPosts {
            self.reloadTableView()
        }
    }
    
    // MARK: - Functions
    @objc func refreshControlPulled() {
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

    // MARK: - Extension: Table View Data Source
extension PostListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy h:mm a"
        let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: post.timestamp))
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(dateString)\nBy \(post.username)"
        return cell
        
    }
}
