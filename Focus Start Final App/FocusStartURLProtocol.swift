import Foundation

public final class FocusStartURLProtocol: URLProtocol
{
    static var posts: [[String : String]] =
    [
        ["id" : "1", "text" : "text1", "created" : "2018-04-13 06:15:53"],
        ["id" : "2", "text" : "text2", "created" : "2018-04-13 06:15:53"],
        ["id" : "3", "text" : "text3", "created" : "2018-04-13 06:15:53"],
        ["id" : "4", "text" : "text4", "created" : "2018-04-13 06:15:53"],
        ["id" : "5", "text" : "text5", "created" : "2018-04-13 06:15:53"],
        ["id" : "6", "text" : "text6", "created" : "2018-04-13 06:15:53"],
    ]

    static var comments: [[String : String]] = [
        ["id" : "1", "post_id" : "1", "text" : "comment text1", "created" : "2018-04-13 06:15:53"],
    ]

    open override static func canInit(with request: URLRequest) -> Bool {
        return (request.url?.host == "focus-start-server")
    }

    open override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    open override func startLoading()
    {
        Thread.sleep(forTimeInterval: 1)

        let url = self.request.url!

        var data: Data?
        var error: Error = NSError(domain: "Unexpected error", code: -1, userInfo: nil)
        
        self.handleGetPosts(url: url, data: &data, error: &error)
        self.handleGetComments(url: url, data: &data, error: &error)
        
        self.handlePostPosts(url: url, data: &data, error: &error)
        self.handlePostComments(url: url, data: &data, error: &error)
        
        self.handlePutPosts(url: url, data: &data, error: &error)
        self.handlePutComments(url: url, data: &data, error: &error)
        
        self.handleDeletePosts(url: url, data: &data, error: &error)
        self.handleDeleteComments(url: url, data: &data, error: &error)

        let response = HTTPURLResponse(url: self.request.url!,
                                       statusCode: 200,
                                       httpVersion: "1.1",
                                       headerFields: nil)!

        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        if let data = data
        {
            self.client?.urlProtocol(self, didLoad: data)
        }
        else
        {
            self.client?.urlProtocol(self, didFailWithError: error)
        }

        self.client?.urlProtocolDidFinishLoading(self)
    }

    open override func stopLoading()
    {
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    private func dateFormatter() -> DateFormatter
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
    
    private func handleGetPosts(url: URL, data: inout Data?, error: inout Error)
    {
        if url.absoluteString.hasSuffix("posts") && self.request.httpMethod == "GET"
        {
            if self.request.value(forHTTPHeaderField: "USER_ID") == nil
            {
                data = try? JSONEncoder().encode(FocusStartURLProtocol.posts)
            }
            else
            {
                error = NSError(domain: "USER_ID extra header", code: -1, userInfo: nil)
            }
        }
    }
    
    private func handleGetComments(url: URL, data: inout Data?, error: inout Error)
    {
        if url.deletingLastPathComponent().absoluteString.hasSuffix("comments/") && self.request.httpMethod == "GET"
        {
            if self.request.value(forHTTPHeaderField: "USER_ID") == nil
            {
                let comments = FocusStartURLProtocol.comments.filter {$0["post_id"] == url.lastPathComponent }
                
                data = try? JSONEncoder().encode(comments)
            }
            else
            {
                error = NSError(domain: "USER_ID extra header", code: -1, userInfo: nil)
            }
        }
    }
    
    private func handlePostComments(url: URL, data: inout Data?, error: inout Error)
    {
        if url.absoluteString.hasSuffix("comments") && self.request.httpMethod == "POST"
        {
            if let httpBodyStream = self.request.httpBodyStream
            {
                let body = Data(reading: httpBodyStream)
                
                if self.request.value(forHTTPHeaderField: "USER_ID") != nil
                {
                    do {
                        var comment = try JSONDecoder().decode([String : String].self, from: body)
                        
                        if comment["post_id"] != nil && comment["text"] != nil
                        {
                            comment["id"] = "\(FocusStartURLProtocol.comments.count + 1)"
                            comment["created"] = self.dateFormatter().string(from: Date())
                            
                            FocusStartURLProtocol.comments.append(comment)
                            
                            data = try! JSONEncoder().encode(comment)
                        }
                        else
                        {
                            throw NSError(domain: "comment is invalid", code: -1, userInfo: nil)
                        }
                    }
                    catch let e
                    {
                        error = e
                    }
                }
                else
                {
                    error = NSError(domain: "USER_ID header must be", code: -1, userInfo: nil)
                }
            }
            else
            {
                error = NSError(domain: "httpBody is empty", code: -1, userInfo: nil)
            }
        }
    }
    
    private func handlePostPosts(url: URL, data: inout Data?, error: inout Error)
    {
        if url.absoluteString.hasSuffix("posts") && self.request.httpMethod == "POST"
        {
            if self.request.value(forHTTPHeaderField: "USER_ID") != nil
            {
                if let httpBodyStream = self.request.httpBodyStream
                {
                    let body = Data(reading: httpBodyStream)
                    
                    do {
                        var post = try JSONDecoder().decode([String : String].self, from: body)
                        
                        if post["text"] != nil
                        {
                            post["id"] = "\(FocusStartURLProtocol.posts.count + 1)"
                            post["created"] = self.dateFormatter().string(from: Date())
                            
                            FocusStartURLProtocol.posts.append(post)
                            
                            data = try! JSONEncoder().encode(post)
                        }
                        else
                        {
                            throw NSError(domain: "post is invalid", code: -1, userInfo: nil)
                        }
                    }
                    catch let e
                    {
                        error = e
                    }
                }
                else
                {
                    error = NSError(domain: "USER_ID header must be", code: -1, userInfo: nil)
                }
            }
            else
            {
                error = NSError(domain: "httpBody is empty", code: -1, userInfo: nil)
            }
        }
    }
    
    private func handlePutPosts(url: URL, data: inout Data?, error: inout Error)
    {
        if url.absoluteString.hasSuffix("posts") && self.request.httpMethod == "PUT"
        {
            if self.request.value(forHTTPHeaderField: "USER_ID") != nil
            {
                if let httpBodyStream = self.request.httpBodyStream
                {
                    let body = Data(reading: httpBodyStream)
                    
                    do {
                        var post = try JSONDecoder().decode([String : String].self, from: body)
                        
                        if post["text"] != nil && post["id"] != nil
                        {
                            var epdatedPost: [String: String]?
                            
                            for i in 0..<FocusStartURLProtocol.posts.count
                            {
                                if FocusStartURLProtocol.posts[i]["id"] == post["id"]
                                {
                                    FocusStartURLProtocol.posts[i]["text"] = post["text"]
                                    FocusStartURLProtocol.posts[i]["updated"] = self.dateFormatter().string(from: Date())
                                    
                                    epdatedPost = FocusStartURLProtocol.posts[i]
                                    
                                    break
                                }
                            }
                            
                            if let epdatedPost = epdatedPost
                            {
                                data = try! JSONEncoder().encode(epdatedPost)
                            }
                            else
                            {
                                throw NSError(domain: "post id unexists", code: -1, userInfo: nil)
                            }
                        }
                        else
                        {
                            throw NSError(domain: "post is invalid", code: -1, userInfo: nil)
                        }
                    }
                    catch let e
                    {
                        error = e
                    }
                }
                else
                {
                    error = NSError(domain: "USER_ID header must be", code: -1, userInfo: nil)
                }
            }
            else
            {
                error = NSError(domain: "httpBody is empty", code: -1, userInfo: nil)
            }
        }
    }
    
    private func handlePutComments(url: URL, data: inout Data?, error: inout Error)
    {
        if url.absoluteString.hasSuffix("comments") && self.request.httpMethod == "PUT"
        {
            if self.request.value(forHTTPHeaderField: "USER_ID") != nil
            {
                if let httpBodyStream = self.request.httpBodyStream
                {
                    let body = Data(reading: httpBodyStream)
                    
                    do {
                        var comment = try JSONDecoder().decode([String : String].self, from: body)
                        
                        if comment["text"] != nil && comment["id"] != nil
                        {
                            var updatedComment: [String: String]?
                            
                            for i in 0..<FocusStartURLProtocol.comments.count
                            {
                                if FocusStartURLProtocol.comments[i]["id"] == comment["id"]
                                {
                                    FocusStartURLProtocol.comments[i]["text"] = comment["text"]
                                    FocusStartURLProtocol.comments[i]["updated"] = self.dateFormatter().string(from: Date())
                                    
                                    updatedComment = FocusStartURLProtocol.comments[i]
                                    
                                    break
                                }
                            }
                            
                            if let updatedComment = updatedComment
                            {
                                data = try! JSONEncoder().encode(updatedComment)
                            }
                            else
                            {
                                throw NSError(domain: "comment id unexists", code: -1, userInfo: nil)
                            }
                        }
                        else
                        {
                            throw NSError(domain: "comment is invalid", code: -1, userInfo: nil)
                        }
                    }
                    catch let e
                    {
                        error = e
                    }
                }
                else
                {
                    error = NSError(domain: "USER_ID header must be", code: -1, userInfo: nil)
                }
            }
            else
            {
                error = NSError(domain: "httpBody is empty", code: -1, userInfo: nil)
            }
        }
    }
    
    private func handleDeletePosts(url: URL, data: inout Data?, error: inout Error)
    {
        if url.deletingLastPathComponent().absoluteString.hasSuffix("posts/") && self.request.httpMethod == "DELETE"
        {
            if self.request.value(forHTTPHeaderField: "USER_ID") != nil
            {
                let i = FocusStartURLProtocol.posts.index(where: {
                    $0["id"] == url.lastPathComponent
                })
                
                if let i = i
                {
                    FocusStartURLProtocol.posts.remove(at: i)
                    
                    data = try! JSONEncoder().encode(["status" : "OK"])
                }
                else
                {
                    error = NSError(domain: "post id unexists", code: -1, userInfo: nil)
                }
            }
            else
            {
                error = NSError(domain: "httpBody is empty", code: -1, userInfo: nil)
            }
        }
    }
    
    private func handleDeleteComments(url: URL, data: inout Data?, error: inout Error)
    {
        if url.deletingLastPathComponent().absoluteString.hasSuffix("comments/") && self.request.httpMethod == "DELETE"
        {
            if self.request.value(forHTTPHeaderField: "USER_ID") != nil
            {
                let i = FocusStartURLProtocol.comments.index(where: {
                    $0["id"] == url.lastPathComponent
                })
                
                if let i = i
                {
                    FocusStartURLProtocol.comments.remove(at: i)
                    
                    data = try! JSONEncoder().encode(["status" : "OK"])
                }
                else
                {
                    error = NSError(domain: "comment id unexists", code: -1, userInfo: nil)
                }
            }
            else
            {
                error = NSError(domain: "httpBody is empty", code: -1, userInfo: nil)
            }
        }
    }
}

extension Data
{
    init(reading input: InputStream)
    {
        self.init()
        
        input.open()

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        
        while input.hasBytesAvailable
        {
            let read = input.read(buffer, maxLength: bufferSize)
            self.append(buffer, count: read)
        }
        
//        buffer.deallocate(capacity: bufferSize)
        buffer.deallocate()
        
        input.close()
    }
}
