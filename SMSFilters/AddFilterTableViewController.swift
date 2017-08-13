//
//  AddFilterTableViewController.swift
//  SMSFilters
//
//  Created by levantAJ on 8/12/17.
//  Copyright © 2017 levantAJ. All rights reserved.
//

import UIKit

protocol AddFilterTableViewControllerDelegate: class {
    func addFilterTableViewController(_ controller: AddFilterTableViewController, didAddFilter filter: Filter)
}

final class AddFilterTableViewController: UITableViewController {
    weak var delegate: AddFilterTableViewControllerDelegate?
    
    @IBOutlet weak var keywordTextField: UITextField!
    
    lazy var filter: Filter = Filter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "New Filter"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keywordTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToMatchingType" {
            let matchingTypeVC = segue.destination as? MatchingTypesTableViewController
            matchingTypeVC?.filterType = filter.type
            matchingTypeVC?.delegate = self
        }
    }
}

// MARK: - Users Interactions

extension AddFilterTableViewController {
    @IBAction func keywordTextFieldDidChangeText(textField: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = !keywordTextField.text!.isEmpty
    }
    
    @IBAction func doneButtonTapped(sender: Any) {
        filter.keyword = keywordTextField.text!
        delegate?.addFilterTableViewController(self, didAddFilter: filter)
        keywordTextField.resignFirstResponder()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: Any) {
        keywordTextField.resignFirstResponder()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension AddFilterTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            cell.detailTextLabel?.text = filter.type.title
        }
    }
}


// MARK: - UITableViewDelegate

extension AddFilterTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - MatchingTypesTableViewControllerDelegate

extension AddFilterTableViewController: MatchingTypesTableViewControllerDelegate {
    func matchingTypesTableViewController(_ controller: MatchingTypesTableViewController, didSelectFilterType filterType: FilterType) {
        filter.type = filterType
        tableView.reloadData()
    }
}
