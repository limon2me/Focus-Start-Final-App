//
//  PostsListVC.swift
//  EyeOfTheTiger
//
//  Created by Vladimir Khabarov on 14.04.2018.
//  Copyright © 2018 FTC. All rights reserved.
//

import UIKit


let CELL = "myCustomCell"
let COMMENTLISTVC = "CommentListVC"
let ADDNEWENTITYVC = "AddNewEntityVC"

class PostListVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var myTableView: UITableView! {
        didSet {
            if #available(iOS 10.0, *) {
                myTableView.refreshControl = self.refreshControl
            } else {
                myTableView.addSubview(self.refreshControl)
            }
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
        }
    }
    
    let model = Model()
    var posts = [Post]() {
        didSet {
            DispatchQueue.main.async {
                self.myTableView.allowsSelection = !self.emptyData
            }
        }
    }
    var emptyData: Bool {
        get {
            return self.posts.isEmpty
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myTableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        
        self.fetchAllPosts()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if let index = self.myTableView.indexPathForSelectedRow
        {
            self.myTableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchAllPosts()
    }

    // MARK: NAVIGATION    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let editRowAction = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            
            let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: ADDNEWENTITYVC) as! AddNewEntityVC
            let post = self.posts[indexPath.row]
            
            destinationVC.text = post.text
            
            destinationVC.passBackClosure = { [unowned self] (text: String) in
                
                self.model.editPost(post, with: text, completionHandler: { (newPost: Post?, error: Error?) in
                    
                    if let newPost = newPost
                    {
                        self.posts[indexPath.row] = newPost
                    }
                })
                self.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
        editRowAction.backgroundColor = self.lightBlue
        
        let deleteRowAction = UITableViewRowAction(style: .default, title: "Delete"){ (action, indexPath) in
            
            self.model.deletePost(post: self.posts[indexPath.row], completionHandler: { [unowned self] (_: [String: String]?, _: Error?) in
                
                self.posts.remove(at: indexPath.row)
                
                DispatchQueue.main.async {
                    if !self.emptyData {
                        tableView.deleteRows(at: [indexPath], with: .left)
                    } else {
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            })
        }
        deleteRowAction.backgroundColor = UIColor.red
        
        return [deleteRowAction, editRowAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: COMMENTLISTVC) as! CommentsListVC
        destinationVC.model = self.model
        destinationVC.post = self.posts[indexPath.row]
        
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @IBAction func addNewPost(_ sender: Any)
    {
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: ADDNEWENTITYVC) as! AddNewEntityVC
        destinationVC.passBackClosure = { (text: String) in
            
            self.model.sendPost(with: text, completionHandler: { (_: Post?, error: Error?) in
                
//                print(error!)
                })
            
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func showActionSheet(errorText: String)
    {
        let actionSheet = UIAlertController(title: "Error", message: errorText, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Reload", style: .default, handler: { (_: UIAlertAction) in
            
            self.fetchAllPosts()
        }))
        
        self.navigationController?.present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: REFRESH_CONTROL
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(handleRefresh),
                                 for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    @objc func handleRefresh()
    {
        self.model.fetchAllPosts { [unowned self] (posts: [Post]?, error: Error?) in

            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
            
            if let fetchedPosts = posts {
                self.posts = fetchedPosts
                
                //TODO: batch update table / startUpdate
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                }
            } else {
                self.errorHandler(error)
            }
        }
    }
    
    //MARK: HELPERS
    func fetchAllPosts()
    {
        self.activityIndicator.startAnimating()
        
        //TODO: !!! [weak self] !!!
        self.model.fetchAllPosts { [unowned self] (posts: [Post]?, error: Error?) in
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            if let fetchedPosts = posts {
                self.posts = fetchedPosts
                
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                }
            } else {
                self.errorHandler(error)
            }
        }
    }
    
    func errorHandler(_ error: Error?)
    {
        let errorText = error?.localizedDescription ?? "Unexpected error"
        self.showActionSheet(errorText: errorText)
    }
    
    lazy var lightBlue: UIColor = {
        return UIColor(red: 29/255, green: 155/255, blue: 246/255, alpha: 1.0)
    }()
}

extension PostListVC
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.emptyData ? 1 : self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL, for: indexPath) as! MyTableViewCell
        
        if self.emptyData
        {
            cell.textLabel?.text = "No posts"
            cell.detailTextLabel?.text = ""
        }
        else
        {
            let post = self.posts[indexPath.row]
            cell.textLabel?.text = post.text
            cell.detailTextLabel?.text = DateUtility.dateFrom(post)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !self.emptyData
    }
}
