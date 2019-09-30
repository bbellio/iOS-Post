//
//  PostController.swift
//  Post
//
//  Created by Bethany Wride on 9/30/19.
//  Copyright © 2019 Bethany Wride. All rights reserved.
//

import Foundation

class PostController {
    // Source of Truth
    var posts: [Post] = []
    
    // Base URL
    let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    
    // escaping -> void is type
    func fetchPosts(completion: @escaping () -> Void) {
        guard let url = baseURL else {
            fatalError("URL is nil")
        }
        // Appends with .json at the end
        let getterEndPoint = url.appendingPathExtension("json")
        var request = URLRequest(url: getterEndPoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion()
                return
            }
            guard let data = data else {
                print("No data")
                completion()
                return
            }
            let jsonDecoder = JSONDecoder()

            // Dictionary of string to post (from API)
            guard let postsDictionary = try? jsonDecoder.decode([String: Post].self, from: data) else {
                print("Error decoding data")
                completion()
                return
            }
            
            // Anonymous closure - returns the second argument in the closure (Post); returns an array of Posts; shorthand allows you to ignore parenthesis if the last argument in the closure is the only one you're using
            let posts = postsDictionary.compactMap { $1 }
            // sorted takes in a closure as an argument - two posts, and returns a bool (true = first arugment should be ordered before its second
            let sortedPosts = posts.sorted { $0.timestamp > $1.timestamp }
            // Assigns the right to the left
            self.posts = sortedPosts
            completion()
        }
        dataTask.resume()
    }
}
 
 
