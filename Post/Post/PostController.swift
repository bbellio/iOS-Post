//
//  PostController.swift
//  Post
//
//  Created by Bethany Wride on 9/30/19.
//  Copyright © 2019 Bethany Wride. All rights reserved.
//

import Foundation

class PostController {
    // MARK: - Global variables
    // Source of Truth
    var posts: [Post] = []
    
    // Base URL
    let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts")
    
    // MARK: - Functions
    // escaping -> void is type
    func fetchPosts(reset: Bool = true, completion: @escaping () -> Void) {
        guard let unwrappedURL = baseURL else {
            fatalError("URL is nil")
        }
        // Appends with .json at the end
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        // \" represents a quotation mark
        let urlParameters = ["orderBy" : "\"timestamp\"", "endAt" : "\(queryEndInterval)", "limitToLast": "15"]
        let queryItems = urlParameters.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else { return }
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
            //            do {
            //                let postsDictionary = try jsonDecoder.decode([String:Post].self, from: data)
            //            } catch {
            //                completion
            //                print("This is our problem")
            //            }
            //
            // Anonymous closure - returns the second argument in the closure (Post); returns an array of Posts; shorthand allows you to ignore parenthesis if the last argument in the closure is the only one you're using
            let posts = postsDictionary.compactMap { $0.value }
            // sorted takes in a closure as an argument - two posts, and returns a bool (true = first arugment should be ordered before its second
            let sortedPosts = posts.sorted { $0.timestamp > $1.timestamp } 
            // Assigns the right to the left
            if reset {
                self.posts = sortedPosts
            } else {
                self.posts.append(contentsOf: sortedPosts)
            }
            completion()
        }
        dataTask.resume()
    } // End of function
    
    func addNewPostWith(username: String, text: String, completion: @escaping () -> Void) {
        let newPost = Post(username: username, text: text)
        var postData: Data
        do {
            postData = try JSONEncoder().encode(newPost)
        } catch {
            print("Error in encoding data : \(error.localizedDescription) \n---\n \(error)")
            return
        }
        guard let baseURL = baseURL else { return }
        let postEndpoint = baseURL.appendingPathExtension("json")
        var urlRequest = URLRequest(url: postEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postData
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error in dataTask: \(error.localizedDescription) \n---\n \(error)")
                completion()
                return
            }
            
            guard let data = data else {
                print("No data")
                completion()
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Unrecognized response")
                completion()
                return
            }
            
            if httpResponse.statusCode == 200, let result = String(data: data, encoding: .utf8) {
                print(result)
                self.fetchPosts {
                    completion()
                }
            } else {
                print("Status code: \(httpResponse.statusCode)")
                completion()
            }
        }.resume()
    } // End of function
} // End of class


