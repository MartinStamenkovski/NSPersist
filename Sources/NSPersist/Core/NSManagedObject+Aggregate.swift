//
//  NSManagedObject+Aggregate.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 4/26/20.
//

import CoreData

public typealias Key = String

public enum Aggregate {
    case average
    case count
    case sum
    case max
    case min
    
    var operation: String {
        switch self {
        case .average:
            return "average:"
        case .count:
            return "count:"
        case .sum:
            return "sum:"
        case .max:
            return "max:"
        case .min:
            return "min:"
        }
    }
    
    var name: String {
        switch self {
        case .average:
            return "average"
        case .count:
            return "count"
        case .sum:
            return "sum"
        case .max:
            return "max"
        case .min:
            return "min"
        }
    }
}

@available(iOS 10, OSX 10.12, watchOS 3.0, tvOS 10, *)
extension NSManagedObject {
    
    public static func aggregate(groupBy keys: [String]? = nil, for key: String, type: Aggregate, completion: ((NSFetchRequest<NSFetchRequestResult>) -> Void)? = nil) -> [[String: Any]]? {
        let keypathExpression = NSExpression(forKeyPath: key) 
        let expression = NSExpression(forFunction: type.operation, arguments: [keypathExpression])
        
        let countExpression = NSExpressionDescription()
        countExpression.expression = expression
        countExpression.name = type.name
        countExpression.expressionResultType = .integer64AttributeType
        
        var propertiesToFetch: [Any] = keys ?? []
        propertiesToFetch.append(countExpression)
        
        let request = fetchRequest()
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = keys
        request.propertiesToFetch = propertiesToFetch
        request.resultType = .dictionaryResultType
        
        completion?(request)
        
        let context = NSPersist.shared.viewContext
        do {
            return try context.fetch(request) as? [[String: Any]]
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        return nil
    }
}
