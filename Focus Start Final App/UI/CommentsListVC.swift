//
//  CommentsListVC.swift
//  EyeOfTheTiger
//
//  Created by Vladimir Khabarov on 14.04.2018.
//  Copyright © 2018 FTC. All rights reserved.
//

import UIKit

class CommentsListVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
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
    
    var model: Model?
    var post: Post?
    var comments = [Comment]()
    var emptyData: Bool {
        get {
            return self.comments.isEmpty
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myTableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(rightBarButtonTap))
        
        self.fetchAllComments()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if let index = self.myTableView.indexPathForSelectedRow
        {
            self.myTableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchAllComments()
    }

    // MARK: NAVIGATION
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let editRowAction = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            
            let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: ADDNEWENTITYVC) as! AddNewEntityVC
            let comment = self.comments[indexPath.row]
            
            destinationVC.text = comment.text
            
            destinationVC.passBackClosure = { (text: String) in
                
                if let model = self.model {
                    
                    model.editComment(comment, with: text, completionHandler: { [unowned self] (newComment: Comment?, error: Error?) in
                        
                        if let newComment = newComment
                        {
                            self.comments[indexPath.row] = newComment
                        }
                    })
                    
                }
                self.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
        editRowAction.backgroundColor = self.lightBlue
        
        let deleteRowAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            if let model = self.model
            {
                model.deleteComment(comment: self.comments[indexPath.row], completionHandler: { [unowned self] (_: [String: String]?, _: Error?) in
                    
                    self.comments.remove(at: indexPath.row)
                    
                    DispatchQueue.main.async {
                        if !self.emptyData {
                            tableView.deleteRows(at: [indexPath], with: .left)
                        } else {
                            tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                })
            }
        }
        deleteRowAction.backgroundColor = UIColor.red
        
        return [deleteRowAction, editRowAction]
    }
    
    func showActionSheet(errorText: String)
    {
        let actionSheet = UIAlertController(title: "Error: comments unavailible", message: errorText, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.navigationController?.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func rightBarButtonTap()
    {
        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: ADDNEWENTITYVC) as? AddNewEntityVC {
        
            if let model = self.model, let post = self.post {
                
                destinationVC.passBackClosure = { (text: String) in
                    
                    model.sendComment(with: text, forPost: post, completionHandler: { (_: Comment?, error: Error?) in
                        
//                        print(error!)
                    })
                    self.navigationController?.popViewController(animated: true)
                }
                navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
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
        if let model = self.model, let post = self.post
        {
            self.postTextLabel.text = post.text
            self.postDateLabel.text = DateUtility.dateFrom(post)
            
            model.fetchAllComments(for: post, completionHandler: { [unowned self] (comments: [Comment]?, error: Error?) in
                
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
                
                if let fetchedComments = comments {
                    self.comments = fetchedComments
                    
                    DispatchQueue.main.async {
                        self.myTableView.reloadData()
                    }
                } else {
                    self.errorHandler(error)
                }
            })
        }
    }
    
    //MARK: HELPERS
    func fetchAllComments()
    {
        self.activityIndicator.startAnimating()
        
        if let model = self.model, let post = self.post
        {
            self.postTextLabel.text = post.text
            self.postDateLabel.text = DateUtility.dateFrom(post)
            
            model.fetchAllComments(for: post, completionHandler: { [unowned self] (comments: [Comment]?, error: Error?) in
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                
                if let fetchedComments = comments {
                    self.comments = fetchedComments
                    
                    DispatchQueue.main.async {
                        self.myTableView.reloadData()
                    }
                } else {
                    self.errorHandler(error)
                }
            })
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

extension CommentsListVC
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.emptyData ? 1 : self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL, for: indexPath) as! MyTableViewCell
        
        if self.emptyData
        {
            cell.textLabel?.text = "No comments"
            cell.detailTextLabel?.text = ""
        }
        else
        {
            cell.textLabel?.text = self.comments[indexPath.row].text
            cell.detailTextLabel?.text = DateUtility.dateFrom(self.comments[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !self.emptyData
    }
}
