//
//  DatabaseService.swift
//  MVL
//
//  Created by Thy Nguyen on 11/13/21.
//

import RxSwift
import CoreData

protocol DatabaseService: class {
    func savePoint(point: PointHolder) -> Single<Void>
    func getSearchedPoints() -> Single<[PointHolder]>
}

final class MainDatabaseService: DatabaseService {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = CoreDataStack()) {
        self.coreDataStack = coreDataStack
    }
    
    func savePoint(point: PointHolder) -> Single<Void> {
        return Single<Void>.create(subscribe: { [weak self] single -> Disposable in
            guard let self = self else { return Disposables.create() }
            let taskContext = self.coreDataStack.newBackgroundContext
            taskContext.performAndWait {
                let matchingDataRequest: NSFetchRequest<PointCD> = PointCD.fetchRequest()
                matchingDataRequest.predicate = NSPredicate(format: "latitude == %@ && longitude == %@ && timestamp == %@", argumentArray: ["\(point.latitude ?? 0.0)", "\(point.longitude ?? 0.0)", "\(point.timestamp ?? 0.0)"])
                
                // Delete outdated records
                if let result = try? taskContext.fetch(matchingDataRequest) {
                    for pointCD in result {
                        taskContext.delete(pointCD)
                    }
                }
                
                // Create new records
                let pointCD = PointCD(context: taskContext)
                pointCD.update(with: point)

                // Save all the changes just made
                if taskContext.hasChanges {
                    do {
                        try taskContext.save()
                    } catch {
                        print("Error: \(error)\nCould not save Core Data context.")
                        single(.failure(NSError(domain: "", code: -1, userInfo: ["Error": "Could not save Core Data context."])))
                    }
                }
                single(.success(()))
            }
            return Disposables.create()
        })
    }
    
    func getSearchedPoints() -> Single<[PointHolder]> {
        return Single<[PointHolder]>.create(subscribe: { [weak self] single -> Disposable in
            guard let self = self else { return Disposables.create() }
            let taskContext = self.coreDataStack.newBackgroundContext
            taskContext.performAndWait {
                let fetchRequest: NSFetchRequest<PointCD> = PointCD.fetchRequest()
                let sort = NSSortDescriptor(key: "timestamp", ascending: false)
                fetchRequest.sortDescriptors = [sort]
                do {
                    let pointCDs = try taskContext.fetch(fetchRequest)
                    let points = pointCDs.compactMap { $0.pointHolder }
                    single(.success(points))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        })
    }
    
}
