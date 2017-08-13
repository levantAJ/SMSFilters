//
//  FiltersTableViewController.swift
//  SMSFilters
//
//  Created by levantAJ on 8/12/17.
//  Copyright © 2017 levantAJ. All rights reserved.
//

import UIKit

final class FiltersTableViewController: UITableViewController {
    fileprivate lazy var filters: [Filter] = []
    fileprivate lazy var defaultFilters: [Filter] = []
    fileprivate var selectAllBarButtonItem: UIBarButtonItem!
    fileprivate var deteteBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToAddFilter" {
            let addFilterVC = (segue.destination as? UINavigationController)?.topViewController as? AddFilterTableViewController
            addFilterVC?.delegate = self
        }
    }
    
    override func delete(_ sender: Any?) {
        if deteteBarButtonItem.title == Constant.FiltersTableViewController.DeleteAll {
            for row in [Int](0..<filters.count) {
                let indexPath = IndexPath(row: row, section: 0)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
        if let indexPathes = tableView.indexPathsForSelectedRows {
            var deletingFilters: [Filter] = []
            for indexPath in indexPathes {
                filters[indexPath.row].delete()
                deletingFilters.append(filters[indexPath.row])
            }
            for filter in deletingFilters {
                if let index = filters.index(where: { $0 == filter }) {
                    filters.remove(at: index)
                }
            }
            tableView.deleteRows(at: indexPathes, with: .automatic)
        }
        if filters.isEmpty {
            reloadData(nil)
        }
    }
    
    override func selectAll(_ sender: Any?) {
        let isSelectingAll = selectAllBarButtonItem.title == Constant.FiltersTableViewController.SelectAll
        for row in [Int](0..<filters.count) {
            let indexPath = IndexPath(row: row, section: 0)
            if isSelectingAll {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        selectAllBarButtonItem.title = isSelectingAll ? Constant.FiltersTableViewController.DeselectAll : Constant.FiltersTableViewController.SelectAll
        deteteBarButtonItem.title = isSelectingAll ? Constant.FiltersTableViewController.Delete : Constant.FiltersTableViewController.DeleteAll
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        navigationController?.setToolbarHidden(!editing, animated: animated)
        selectAllBarButtonItem.title = Constant.FiltersTableViewController.SelectAll
        deteteBarButtonItem.title = Constant.FiltersTableViewController.DeleteAll
        super.setEditing(editing, animated: animated)
    }
}

// MARK: - Users Interactions

extension FiltersTableViewController {
    @IBAction func reloadData(_ sender: Any?) {
        setEditing(false, animated: true)
        refreshControl?.beginRefreshing()
        DispatchQueue(label: "com.levantAJ.SMSFilters.queue").async { [weak self] in
            self?.filters = Filter.storagedFilters
            self?.defaultFilters = Filter.defaultFilters
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
                self?.editButtonItem.isEnabled = self?.filters.isEmpty == false
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension FiltersTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return filters.count
        }
        return defaultFilters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let keyword: String
        let filterName: String
        let selectionStyle: UITableViewCellSelectionStyle
        if indexPath.section == 0 {
            keyword = filters[indexPath.row].keyword
            filterName = filters[indexPath.row].type.title
            selectionStyle = .blue
        } else {
            keyword = defaultFilters[indexPath.row].keyword
            filterName = defaultFilters[indexPath.row].type.title
            selectionStyle = .none
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell", for: indexPath)
        cell.textLabel?.text = keyword
        cell.detailTextLabel?.text = filterName
        cell.selectionStyle = selectionStyle
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FiltersTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deteteBarButtonItem.title = Constant.FiltersTableViewController.Delete
        selectAllBarButtonItem.title = tableView.indexPathsForSelectedRows?.count == filters.count ? Constant.FiltersTableViewController.DeselectAll : Constant.FiltersTableViewController.SelectAll
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                filters[indexPath.row].delete()
                filters.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Custom keywords"
        }
        return "Default keywords"
    }
}


// MARK: - AddFilterTableViewControllerDelegate

extension FiltersTableViewController: AddFilterTableViewControllerDelegate {
    func addFilterTableViewController(_ controller: AddFilterTableViewController, didAddFilter filter: Filter) {
        filter.save()
        reloadData(nil)
    }
}

// MARK: - Privates

extension FiltersTableViewController {
    fileprivate func setupViews() {
        navigationItem.leftBarButtonItem = editButtonItem
        selectAllBarButtonItem = UIBarButtonItem()
        selectAllBarButtonItem.title = Constant.FiltersTableViewController.SelectAll
        selectAllBarButtonItem.target = self
        selectAllBarButtonItem.action = #selector(selectAll(_:))
        
        deteteBarButtonItem = UIBarButtonItem()
        deteteBarButtonItem.title = Constant.FiltersTableViewController.DeleteAll
        deteteBarButtonItem.target = self
        deteteBarButtonItem.action = #selector(delete(_:))
        
        toolbarItems = [selectAllBarButtonItem, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), deteteBarButtonItem]
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        reloadData(nil)
    }
}

extension Constant {
    struct FiltersTableViewController {
        static let SelectAll = "Select all"
        static let DeselectAll = "Deselect all"
        static let Delete = "Delete"
        static let DeleteAll = "Delete all"
    }
}

