//
//  LogoutOptionsViewController.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import UIKit

enum LogoutType: String, CaseIterable {
    case revokeTokens = "Revoke Tokens"
    case browserSession = "Browser Session"
    case appSession = "App Session"
}

typealias LogoutAlertCompletionHandler = (Result<Bool, Error>) -> Void
protocol LogoutAlertDelegate: AnyObject {
    func handleLogoutSelections(_ selections: Set<LogoutType>, completion: LogoutAlertCompletionHandler?)
}

class LogoutOptionsAlertController: UIAlertController {
    
    weak var delegate: LogoutAlertDelegate?
    var completionHandler: LogoutAlertCompletionHandler?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let logoutViewController = LogoutOptionsViewController()
        setValue(logoutViewController, forKey: "contentViewController")
        
        let cancelAction = UIAlertAction(title: TextConstants.cancel, style: .cancel) { result in
            if let completionHandler = self.completionHandler {
                completionHandler(Result.success(false))
            }
        }
        let submitAction = UIAlertAction(title: TextConstants.submit, style: .default) { _ in
            self.delegate?.handleLogoutSelections(logoutViewController.selectedLogoutOptions, completion: self.completionHandler ?? nil)
        }
        
        addAction(cancelAction)
        addAction(submitAction)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class LogoutOptionsViewController: UIViewController {
    var selectedLogoutOptions: Set<LogoutType> = []
    private var tableViewLogoutOptions = LogoutType.allCases
    
    override func viewDidLoad() {
        print("\(type(of: self)) did load")
        super.viewDidLoad()
        
        createTableView()
    }
    
    private func createTableView() {
        
        let rect = CGRect(x: 0, y: 0, width: 300.0, height: LogoutOptionsControllerCell.height() * Double(tableViewLogoutOptions.count))
        preferredContentSize = rect.size
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: true)
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
        
        view.addSubview(tableView)
        view.bringSubviewToFront(tableView)
        view.isUserInteractionEnabled = true
    }
}

//MARK: UITableView Delegates and DataSource
extension LogoutOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewLogoutOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = LogoutOptionsControllerCell(style: .default, reuseIdentifier: LogoutOptionsControllerCell.identifier)
        
        let object = tableViewLogoutOptions[indexPath.row]
        cell.setData(object)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLogoutOptionToAdd = tableViewLogoutOptions[indexPath.row]
        
        selectedLogoutOptions.insert(selectedLogoutOptionToAdd)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedLogoutOptionToRemove = tableViewLogoutOptions[indexPath.row]
        
        selectedLogoutOptions.remove(selectedLogoutOptionToRemove)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LogoutOptionsControllerCell.height()
    }
}
