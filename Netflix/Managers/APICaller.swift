//
//  APICaller.swift
//  Netflix
//
//  Created by yudonlee on 2022/07/09.
//

import Foundation

struct Constants {
    static let API_KEY = "4a09916eaf1807f253b181e44cbc3adc"
    static let baseURL = "https://api.themoviedb.org"
    static let YoutubeAPI_KEY = "AIzaSyBl-CQH6UqejwSa-zTYwGChSdKWVxgrFe8"
    static let YoutubeBaseURL = "https://youtube.googleapis.com/youtube/v3/search?"
}

enum APIError: Error {
    case failedTogetData
    
}
class APICaller {
    static let shared = APICaller()
    
    private var titles: [Title] = []
    
    func getTrendingMovies(completion: @escaping (Result<[Title], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/3/trending/movie/day?api_key=\(Constants.API_KEY)") else {
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                // 우리 data를 json object로 바꾸기
//                let results = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(results.results))
//                print(results.results[0].original_title)
            } catch {
                completion(.failure(APIError.failedTogetData))
            }
        }
        task.resume()
    }
//    TODO: Result가 무엇인지, escaping이 무엇을 의미하는지?
    func getTrendingTvs(completion: @escaping (Result<[Title], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/3/trending/tv/day?api_key=\(Constants.API_KEY)") else {
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) {
            data, _, error in
            guard let data = data, error == nil  else { return }
            do {
//                TODO: JSONSerial과 decode의 차이, JSONSerial이 상대적으로 간단하게 받는거 같음
//                let results = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
//                print(results)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedTogetData))
            }
        }
        task.resume()
    }
    
    func getUpcomingMovies(completion: @escaping (Result<[Title], Error>) -> Void) {
        guard let url = URL(string:  "\(Constants.baseURL)/3/movie/upcoming?api_key=\(Constants.API_KEY)&language=ko-KR&page=1") else {
            return
            
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
//                let results = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                
//                print(results)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedTogetData))
            }
        }
        task.resume()
    }
    
    func getPopular(completion: @escaping (Result<[Title], Error>) -> Void) {
        guard let url = URL(string:  "\(Constants.baseURL)/3/movie/popular?api_key=\(Constants.API_KEY)&language=ko-KR&page=1") else {
            return
            
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
//                let results = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(results.results))
//                print(results)
            } catch {
                completion(.failure(APIError.failedTogetData))
            }
        }
        task.resume()
    }
    
    func getTopRated(completion: @escaping (Result<[Title], Error>) -> Void) {
        guard let url = URL(string:  "\(Constants.baseURL)/3/movie/popular?api_key=\(Constants.API_KEY)&language=ko-KR&page=1") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                print(results)
                completion(.success(results.results))
//                completion(.success(API))
            } catch {
                completion(.failure(APIError.failedTogetData))
            }
        }
        task.resume()
    }
    
    func getDiscoverMovies(completion: @escaping (Result<[Title], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/3/discover/movie?api_key=\(Constants.API_KEY)&language=ko-KR&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate") else { return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedTogetData))
            }
        }
        task.resume()
    }
    
    func search(with query: String,  completion: @escaping (Result<[Title], Error>) -> Void) {
//        query를 넘기기전에, query를 format으로 해야한다.
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        guard let url = URL(string: "\(Constants.baseURL)/3/search/movie?api_key=\(Constants.API_KEY)&query=\(query)") else {
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedTogetData))
            }
            
        }
        task.resume()
    }
    
    func getMovie(with query: String, completion: @escaping (Result<VideoElement, Error>) -> Void) {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return
        }
        guard let url = URL(string: "\(Constants.YoutubeBaseURL)q=\(query)&key=\(Constants.YoutubeAPI_KEY)") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(YoutubeSearchResponse.self, from: data)
//                let results = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                if results.items.first != nil, let videoElement = results.items.first {
                    completion(.success(videoElement))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()

    }
}

//\(Constants.baseURL)/3/movie/upcoming?api_key=(Constants.API_KEY)&language=ko-KR&page=1

//https://api.themoviedb.org/3/discover/movie?api_key=4a09916eaf1807f253b181e44cbc3adc&language=ko-KR&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate
