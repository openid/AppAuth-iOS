//
//  LogoutOptionsController.swift
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

class LogoutOptionsController: UIViewController {
    var selectedLogoutOptions: Set<LogoutType> = []
    var tableViewLogoutOptions = LogoutType.allCases

    deinit {
        print("\(type(of: self)) was deallocated")
    }

    override func viewDidLoad() {
        print("\(type(of: self)) did load")
        super.viewDidLoad()

        createTableView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    func createTableView() {

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
extension LogoutOptionsController: UITableViewDelegate, UITableViewDataSource {

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
