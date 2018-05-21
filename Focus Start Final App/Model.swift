//
//  Model.swift
//  EyeOfTheTiger
//
//  Created by Vladimir Khabarov on 12.04.2018.
//  Copyright © 2018 FTC. All rights reserved.
//

import Foundation

class Model
{
    let baseUrl = URL(string: "https://focus-start-server/")!

    var postsUrl: URL {
        get {
            return baseUrl.appendingPathComponent("posts")
        }
    }
    
    var commentsUrl: URL {
        get {
            return baseUrl.appendingPathComponent("comments")
        }
    }
    
    let webRequest: WebRequest = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let webRequest = WebRequest(session: URLSession.focusStartSession, decoder: decoder)
        return webRequest
    }()
    
    let httpParams = ["USER_ID" : User.shared.id]

    
    //MARK: FETCH
    func fetchAllPosts(completionHandler: @escaping (_ result: [Post]?, _ error: Error?) -> Void) {
        
        let request = Request.configure(url: self.postsUrl, httpMethod: "GET", headerFields: [:])
        
        self.fetchData(with: request, completionHandler: completionHandler)
    }

    func fetchAllComments(for post: Post,
                          completionHandler: @escaping (_ result: [Comment]?, _ error: Error?) -> Void) {
        
        let url = self.commentsUrl.appendingPathComponent(post.id)
        let request = Request.configure(url: url, httpMethod: "GET", headerFields: [:])
        
        self.fetchData(with: request, completionHandler: completionHandler)
    }
    
    
    //MARK: DELETE
    func deletePost(post: Post,
                    completionHandler: @escaping (_ result: [String: String]?, _ error: Error?) -> Void) {
        
        let url = self.postsUrl.appendingPathComponent(post.id)
        let request = Request.configure(url: url,
                                        httpMethod: "DELETE",
                                        headerFields: self.httpParams)
        
        self.fetchData(with: request, completionHandler: completionHandler)
    }
    
    func deleteComment(comment: Comment,
                       completionHandler: @escaping (_ result: [String: String]?, _ error: Error?) -> Void) {
        
        let url = self.commentsUrl.appendingPathComponent(comment.id)
        let request = Request.configure(url: url,
                                        httpMethod: "DELETE",
                                        headerFields: self.httpParams)
        
        self.fetchData(with: request, completionHandler: completionHandler)
    }
    
    
    //MARK: SEND
    func sendPost(with text: String,
                  completionHandler: @escaping (_ result: Post?, _ error: Error?) -> Void) {
        
        do {
            let request = try Request.configure(with: ["text" : text],
                                                url: self.postsUrl,
                                                httpMethod: "POST",
                                                headerFields: self.httpParams)
            
            self.fetchData(with: request, completionHandler: completionHandler)
        }
        catch _ {
        }
    }
    
    func sendComment(with text: String,
                         forPost post: Post,
                         completionHandler: @escaping (_ result: Comment?, _ error: Error?) -> Void) {
        
        do {
            let request = try Request.configure(with: ["post_id" : post.id, "text" : text],
                                                url: self.commentsUrl,
                                                httpMethod: "POST",
                                                headerFields: self.httpParams)
            
            self.fetchData(with: request, completionHandler: completionHandler)
        }
        catch _ {
        }
    }
    
    
    //MARK: EDIT
    func editPost(_ post: Post,
                  with text: String,
                  completionHandler: @escaping (_ result: Post?, _ error: Error?) -> Void) {
        
        do {
            let request = try Request.configure(with: ["id" : post.id, "text" : text],
                                                url: self.postsUrl,
                                                httpMethod: "PUT",
                                                headerFields: self.httpParams)
            
            self.fetchData(with: request, completionHandler: completionHandler)
        }
        catch _ {
        }
    }
    
    func editComment(_ comment: Comment,
                     with text: String,
                     completionHandler: @escaping (_ result: Comment?, _ error: Error?) -> Void) {
        
        do {
            let request = try Request.configure(with: ["id" : comment.id, "text" : text],
                                                url: self.commentsUrl,
                                                httpMethod: "PUT",
                                                headerFields: self.httpParams)
            
            self.fetchData(with: request, completionHandler: completionHandler)
        }
        catch _ {
        }
    }
    
    
    //MARK: Private
    private func fetchData<DataType: Codable>(with request: URLRequest,
                                              completionHandler: @escaping (_ result: DataType?, _ error: Error?) -> Void) {
        
        webRequest.perform(request: request, completion: { (result: WebRequest.Result<DataType>) in
            
            switch result
            {
            case .success(let data):
                completionHandler(data, nil)
                
            case .error(let error):
                completionHandler(nil, error)
            }
        })
    }
}
