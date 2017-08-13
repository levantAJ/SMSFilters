//
//  MatchingTypesTableViewController.swift
//  SMSFilters
//
//  Created by levantAJ on 8/12/17.
//  Copyright © 2017 levantAJ. All rights reserved.
//

import UIKit

protocol MatchingTypesTableViewControllerDelegate: class {
    func matchingTypesTableViewController(_ controller: MatchingTypesTableViewController, didSelectFilterType filterType: FilterType)
}

final class MatchingTypesTableViewController: UITableViewController {
    var filterType: FilterType = .contains
    weak var delegate: MatchingTypesTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Matching type"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParentViewController {
            delegate?.matchingTypesTableViewController(self, didSelectFilterType: filterType)
        }
    }
}

// MARK: - UITableViewDataSource

extension MatchingTypesTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.accessoryType = filterType == .contains ? .checkmark : .none
            cell.textLabel?.text = FilterType.contains.title
        } else if indexPath.row == 1 {
            cell.accessoryType = filterType == .prefix ? .checkmark : .none
            cell.textLabel?.text = FilterType.prefix.title
        } else if indexPath.row == 2 {
            cell.accessoryType = filterType == .suffix ? .checkmark : .none
            cell.textLabel?.text = FilterType.suffix.title
        }
    }
}

// MARK: - UITableViewDelegate

extension MatchingTypesTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            filterType = .contains
        } else if indexPath.row == 1 {
            filterType = .prefix
        } else if indexPath.row == 2 {
            filterType = .suffix
        }
        tableView.reloadData()
    }
}
