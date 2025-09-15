import CoreData
import Foundation

extension NSManagedObjectContext {
    
    /// Safely fetch objects with error handling
    func safeFetch<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T] {
        do {
            return try fetch(request)
        } catch {
            throw error
        }
    }
    
    /// Perform background task with error handling
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "CoreDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Context is nil"]))
                    return
                }
                
                do {
                    let result = try block(self)
                    try self.save()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension CoreDataStack {
    
    /// Perform background task with error handling
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        let context = newBackgroundContext()
        return try await context.performBackgroundTask(block)
    }
}
