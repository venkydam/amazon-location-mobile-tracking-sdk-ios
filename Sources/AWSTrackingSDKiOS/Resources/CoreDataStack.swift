import CoreData

internal class CoreDataStack {

    public static let shared = CoreDataStack()

    public lazy var persistentContainer: NSPersistentContainer = {

        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "LocationEntity"
        entity.managedObjectClassName = "LocationEntity"
        model.entities = [entity]

        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false

        let latitudeAttribute = NSAttributeDescription()
        latitudeAttribute.name = "latitude"
        latitudeAttribute.attributeType = .doubleAttributeType

        let longitudeAttribute = NSAttributeDescription()
        longitudeAttribute.name = "longitude"
        longitudeAttribute.attributeType = .doubleAttributeType

        let uploadedAttribute = NSAttributeDescription()
        uploadedAttribute.name = "accuracy"
        uploadedAttribute.attributeType = .doubleAttributeType

        let timestampAttribute = NSAttributeDescription()
        timestampAttribute.name = "timestamp"
        timestampAttribute.attributeType = .dateAttributeType

        entity.properties = [idAttribute, latitudeAttribute, longitudeAttribute, uploadedAttribute, timestampAttribute]
        let container = NSPersistentContainer(name: "Model", managedObjectModel: model)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
