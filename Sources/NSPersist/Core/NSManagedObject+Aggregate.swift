//
//  NSManagedObject+Aggregate.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 4/26/20.
//

import CoreData

///Aggregate type
public enum Aggregate {
    
    ///average of a set.
    case average
    ///number of items in a set
    case count
    ///sum of values in a set.
    case sum
    ///maximum value in a set.
    case max
    ///minimum value in a set.
    case min
    
    ///Aggregate operation to execute.
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
    
    ///Aggregate name in result.
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
    /**
     Aggregate operation.
     
     Perform aggregate operations on a set of values.
     
     - Parameter properties: Properties  to group by.
     - Parameter key: Property  to execute aggregate operation on.
     - Parameter type: Aggregate operation type.
     - Parameter completion: The block to execute when NSFetchRequest is created, for further customization.
     */
    public static func aggregate(groupBy properties: [String]? = nil, for key: String, type: Aggregate, completion: ((NSFetchRequest<NSFetchRequestResult>) -> Void)? = nil) -> [[String: Any]]? {
        let keypathExpression = NSExpression(forKeyPath: key) 
        let expression = NSExpression(forFunction: type.operation, arguments: [keypathExpression])
        
        let countExpression = NSExpressionDescription()
        countExpression.expression = expression
        countExpression.name = type.name
        countExpression.expressionResultType = .integer64AttributeType
        
        var propertiesToFetch: [Any] = properties ?? []
        propertiesToFetch.append(countExpression)
        
        let request = fetchRequest()
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = properties
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
