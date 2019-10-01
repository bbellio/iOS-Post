//
//  PostListViewController.swift
//  Post
//
//  Created by Bethany Wride on 9/30/19.
//  Copyright © 2019 Bethany Wride. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController {
    
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
    // MARK: - Actions
    
    @IBAction func addButtonTapped(_ sender: Any) {
        presentNewPostAlert()
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
    
    func presentNewPostAlert() {
        let alert = UIAlertController(title: "New Post", message: "Type Your Post Here", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Username"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Post your message here..."
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let postAction = UIAlertAction(title: "Post", style: .default) { (_) in
            guard let username = alert.textFields?[0].text, !username.isEmpty,
                let text = alert.textFields?[1].text, !text.isEmpty
                else {
                    self.present(alert, animated: true)
                    return
            }
            self.postController.addNewPostWith(username: username, text: text) {
                self.reloadTableView()
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(postAction)
        present(alert, animated: true)
    }
}

// MARK: - Class Extensions

//Table View Data Source
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

// Table View Delegate
extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row >= postController.posts.count - 1 else { return }
        postController.fetchPosts(reset: false) {
            self.reloadTableView()
        }
    } 
}
