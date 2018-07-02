//
//  RealmManager.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/29/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RealmManager: NSObject {

    static let shared = RealmManager()

    fileprivate let realm: Realm = try! Realm()

    static func listToArray<T: Object>(_ list: List<T>) -> [T] {
        return Array(list)
    }
    
    //MARK: Saving objects
    func saveObject(_ object: Object, update: Bool = true) {
        try! self.realm.write {
            self.realm.add(object, update: update)
        }
    }
    
    func saveObjectsArray(_ objectsArray: [Object], update: Bool = true) {
        try! self.realm.write {
            self.realm.add(objectsArray, update: update)
        }
    }
    
    func saveValue<T: Any>(_ value :T, forKey key: String, toType type: Object.Type) {
        let objects = realm.objects(type)
        try! self.realm.write {
            objects.setValue(value, forKey: key)
        }
    }
    
    func performWrite(_ block: () -> ()) throws {
        try self.realm.write {
            block()
        }
    }
    
}

extension RealmManager {
    //MARK: Geting objects
    func getElement<T: Object>(ofType type: T.Type) -> T? {
        guard let object = realm.objects(type).first else {
            return nil
        }
        return object
    }
    
    func getElement<T: Object>(ofType type: T.Type, filterWith predicate: NSPredicate) -> T? {
        let objects = realm.objects(type).filter(predicate)
        guard let object = objects.first else { return nil }
        return object
    }
    
    //MARK: Getting array
    func getArray<T: Object>(ofType type: T.Type) -> [T] {
        return Array(realm.objects(type))
    }
    
    func getArray<T: Object>(ofType type: T.Type, filterWith predicate: NSPredicate) -> [T] {
        let rawResult = realm.objects(type).filter(predicate)
        return Array(rawResult)
    }
    
    func getResult<T: Object>(ofType type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    func getResult<T: Object>(ofType type: T.Type, filterWith predicate: NSPredicate) -> Results<T> {
        return realm.objects(type).filter(predicate)
    }
}

extension RealmManager {
    //MARK: Deleting objects
    func deleteObject(_ object: Object) {
        try! realm.write {
            realm.delete(object)
        }
    }
    
    func deleteObjectsArray(_ objectArray: [Object]) {
        try! realm.write {
            realm.delete(objectArray)
        }
    }
}

extension RealmManager {
    func checkObjectExisting<T: Object>(ofType type: T.Type) -> Bool {
        return !realm.objects(type).isEmpty
    }
}

extension RealmManager {
    func getThreadSafePointer<T: Object>(to object: T) -> ThreadSafeReference<T> {
        return ThreadSafeReference(to: object)
    }
    
    func getObject<T: Object>(by pointer: ThreadSafeReference<T>) -> T? {
        guard let object = realm.resolve(pointer) else {
            return nil
        }
        return object
    }
}
