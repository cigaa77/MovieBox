//
//  PersistenceController.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 14.09.26.
//

import CoreData

final class PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init() {

        container = NSPersistentContainer(name: "MovieBox")

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data yüklenemedi : \(error)")
            }
        }

    }

    var context: NSManagedObjectContext {
        container.viewContext
    }
}
