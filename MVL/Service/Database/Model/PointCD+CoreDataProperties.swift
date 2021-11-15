//
//  PointCD+CoreDataProperties.swift
//  
//
//  Created by Thy Nguyen on 11/13/21.
//
//

import Foundation
import CoreData

extension PointCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PointCD> {
        return NSFetchRequest<PointCD>(entityName: "PointCD")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: Double

    func update(with point: PointHolder) {
        self.latitude = point.latitude ?? 0.0
        self.longitude = point.longitude ?? 0.0
        self.timestamp = point.timestamp ?? 0.0
    }
    
    var pointHolder: PointHolder {
        let point = PointHolder(pointName: "")
        point.latitude = latitude
        point.longitude = longitude
        point.timestamp = timestamp
        return point
    }
}
