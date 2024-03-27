import CoreLocation
import CoreData

class LocationDatabase {
    
    func save(location: CLLocation?) -> LocationEntity? {
        if (location == nil) {
            return nil
        }
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let newLocationEntity = LocationEntity(context: context)
        newLocationEntity.id = UUID()
        newLocationEntity.longitude = (location?.coordinate.longitude)!
        newLocationEntity.latitude = (location?.coordinate.latitude)!
        newLocationEntity.timestamp = Date()
        newLocationEntity.accuracy = (location?.horizontalAccuracy)!
        
        do {
            try context.save()
            return newLocationEntity
        } catch {
            print("Failed saving")
        }
        return nil
    }
    
    func fetchAll() -> [LocationEntity] {
        do {
            let context = CoreDataStack.shared.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<LocationEntity> = LocationEntity.fetchRequest()
            let locations = try context.fetch(fetchRequest)
            // Now 'locations' contains the fetched LocationEntity objects.
            return locations
        } catch {
            print("Failed to fetch locations: \(error)")
        }
        return []
    }
    
    func delete(locationID: String) {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<LocationEntity> = LocationEntity.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "id == %@", locationID)
        
        do {
            let locations = try context.fetch(fetchRequest)
            
            for location in locations {
                context.delete(location)
            }
            
            try context.save()
        } catch {
            print("Failed to fetch or delete locations: \(error)")
        }
    }
    
    func delete(locations: [LocationEntity]) {
        let context = CoreDataStack.shared.persistentContainer.viewContext
         
        do {
            for location in locations {
                context.delete(location)
            }
            
            try context.save()
        } catch {
            print("Failed to fetch or delete locations: \(error)")
        }
    }
    
    func deleteAll() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<LocationEntity> = LocationEntity.fetchRequest()
        
        do {
            let locations = try context.fetch(fetchRequest)
            
            for location in locations {
                context.delete(location)
            }
            
            try context.save()
        } catch {
            print("Failed to fetch or delete locations: \(error)")
        }
    }
    
    func count() -> Int {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<LocationEntity> = LocationEntity.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch {
            print("Failed to count locations: \(error)")
            return 0
        }
    }
}
