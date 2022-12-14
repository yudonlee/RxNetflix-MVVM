//
//  DataPersistenceManager.swift
//  Netflix
//
//  Created by yudonlee on 2022/09/12.
//
import UIKit
import CoreData

class DataPersistenceManager {
    
    enum DatabaseError: Error {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
        case failedToLoadAppDelegate
    }
    
    static let shared = DataPersistenceManager()
    
    private init() { }
    
    func downloadTitleWith(model: Title) throws -> Bool {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw DatabaseError.failedToLoadAppDelegate
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
//        context manager에게 TitleItem이란걸 만들었다고 알려준다.
        let item = TitleItem(context: context)
        item.original_title = model.original_title
        item.id = Int64(model.id)
        item.original_name = model.original_name
        item.overview = model.overview
        item.media_type = model.media_type
        item.poster_path = model.poster_path
        item.release_date = model.release_date
        item.vote_count = Int64(model.vote_count)
        item.vote_average = model.vote_average

        do {
            try context.save()
            return true
        } catch {
            throw DatabaseError.failedToSaveData
        }
    }
    
    func downloadTitleWith(model: Title, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
              return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
//        context manager에게 TitleItem이란걸 만들었다고 알려준다.
        let item = TitleItem(context: context)
        item.original_title = model.original_title
        item.id = Int64(model.id)
        item.original_name = model.original_name
        item.overview = model.overview
        item.media_type = model.media_type
        item.poster_path = model.poster_path
        item.release_date = model.release_date
        item.vote_count = Int64(model.vote_count)
        item.vote_average = model.vote_average
        
        do {
            try context.save()
//            Void를 넘기는 방법은 empty를 넘기는것
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToSaveData))
        }
        
    }
    
    func fetchingTitlesFromDatabase(completion: @escaping (Result<[TitleItem], Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<TitleItem>
        
        request = TitleItem.fetchRequest()
        
        do {
            let titles = try context.fetch(request)
            completion(.success(titles))
        } catch {
            print(error.localizedDescription)
            completion(.failure(DatabaseError.failedToFetchData))
        }
    }
    
    func deleteTitleWith(model: TitleItem, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(model) // database에 삭제를 요청함
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToDeleteData))
        }
    }
}
