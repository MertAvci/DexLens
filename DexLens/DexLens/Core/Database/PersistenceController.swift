import CoreData
import Foundation

/// A singleton class that manages the Core Data stack for the app.
///
/// `PersistenceController` provides a centralized way to access and manage
/// the Core Data persistent container, including the main view context
/// and background task contexts.
///
/// ## Usage
///
/// ### Accessing the shared instance
/// ```swift
/// let context = PersistenceController.shared.viewContext
/// ```
///
/// ### Performing background operations
/// ```swift
/// PersistenceController.shared.performBackgroundTask { context in
///     // Perform background Core Data operations
/// }
/// ```
///
/// ## Features
/// - Thread-safe singleton pattern
/// - Automatic migration support
/// - Background context for heavy operations
/// - Error handling for save operations
final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    /// The main view context for UI operations.
    ///
    /// Use this context for all UI-thread Core Data operations.
    /// It automatically merges changes from parent contexts.
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    private init() {
        container = NSPersistentContainer(name: "DexLens")

        // Configure persistent store description
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )

        // Use semaphore to make async load synchronous
        // This ensures stores are fully loaded before returning
        let semaphore = DispatchSemaphore(value: 0)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
            }
            semaphore.signal()
        }
        semaphore.wait() // Block until stores are loaded

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Performs a block of work on a background context.
    ///
    /// This method creates a new background context, executes the provided block,
    /// and automatically saves the context if changes were made.
    ///
    /// - Parameter block: A closure that performs Core Data operations on the background context.
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { context in
            block(context)

            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nsError = error as NSError
                    print("Background context save error: \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }

    /// Saves changes in the view context.
    ///
    /// This method should be called after making changes to the view context
    /// to persist them to the persistent store.
    ///
    /// - Throws: An error if the save operation fails.
    func saveViewContext() {
        let context = container.viewContext

        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("View context save error: \(nsError), \(nsError.userInfo)")
        }
    }
}
