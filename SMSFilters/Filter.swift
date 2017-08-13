//
//  Filter.swift
//  SMSFilters
//
//  Created by levantAJ on 8/12/17.
//  Copyright © 2017 levantAJ. All rights reserved.
//

import Foundation

enum FilterType: String, Codable {
    case contains = "contains"
    case prefix = "prefix"
    case suffix = "suffix"
    
    var title: String {
        switch self {
        case .contains:
            return "Contains"
        case .prefix:
            return "Prefix"
        case .suffix:
            return "Suffix"
        }
    }
}

struct Filter: Codable {
    var type: FilterType = .contains
    var keyword: String = ""
    
    func delete() {
        var filters = Filter.storagedFilters
        if let index = filters.index(where: { $0 == self }) {
            filters.remove(at: index)
            guard let jsonString = Filter.jsonString(from: filters) else { return }
            let userDefault = UserDefaults(suiteName: Constant.Storage.GroupName)
            userDefault?.set(jsonString, forKey: Constant.Storage.Filters)
            userDefault?.synchronize()
        }
    }
    
    func save() {
        var filters = Filter.storagedFilters
        if filters.isEmpty {
            filters.append(self)
        } else {
            filters.insert(self, at: 0)
        }
        guard let jsonString = Filter.jsonString(from: filters) else { return }
        let userDefault = UserDefaults(suiteName: Constant.Storage.GroupName)
        userDefault?.set(jsonString, forKey: Constant.Storage.Filters)
        userDefault?.synchronize()
    }
    
    static var storagedFilters: [Filter] {
        let userDefault = UserDefaults(suiteName: Constant.Storage.GroupName)
        guard let string = userDefault?.string(forKey: Constant.Storage.Filters) else { return [] }
        return Filter.filters(from: string)
    }
    
    static var defaultFilters: [Filter] {
        guard let path = Bundle.main.path(forResource: "spam-words", ofType: "txt") else { return [] }
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            let keywords = data.components(separatedBy: .newlines).filter { !$0.isEmpty }
            return keywords.flatMap { Filter(type: .contains, keyword: $0) }
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    static func filters(from string: String) -> [Filter] {
        do {
            guard let json = string.data(using: .utf8) else { return [] }
            return try JSONDecoder().decode(Array<Filter>.self, from: json)
        } catch let error {
            debugPrint(error)
            return []
        }
    }
    
    static func jsonString(from filters: [Filter]) -> String? {
        do {
            let json = try JSONEncoder().encode(filters)
            return String(data: json, encoding: .utf8)
        } catch let error {
            debugPrint(error)
            return nil
        }
    }
}

extension Filter: Equatable {
    public static func ==(lhs: Filter, rhs: Filter) -> Bool {
        return lhs.keyword == rhs.keyword && lhs.type == rhs.type
    }
}

struct Constant {}

extension Constant {
    struct Storage {
        static let GroupName = "group.levantAJ.smsfilters"
        static let Filters = "filters"
    }
}
