//
//  HomeViewModel.swift
//  Netflix
//
//  Created by 이유돈 on 2023/01/02.
//

import RxSwift
import RxCocoa
import Foundation

protocol ViewModel {
    associatedtype Input
    associatedtype Output
}

final class HomeViewModel: ViewModel {
    
    private var disposeBag = DisposeBag()
    let eventUI: PublishRelay<Input> = .init()
    let output: PublishRelay<Output> = .init()
    
    enum Input {
        case requestMovieData(type: Sections)
        case downloadButtonTapped(title: Title)
        case movieCellTapped(title: Title)
        case movieCellDownloadTapped(title: Title)
    }
    
    enum Output {
        //        case movieDataLoaded(titles: [Title])
        case displayMovieDetail(movie: MovieDetail)
    }
    
    init() {
        bind()
    }
    func bind() {
        _ = eventUI.subscribe(onNext: { [weak self] event in
            switch event {
            case .requestMovieData(let section):
                self?.requestMovieSection(type: section)
            case .downloadButtonTapped(let title):
                self?.downloadMovie(title: title)
            case .movieCellTapped(let title):
                self?.requestPreviewMovie(title: title)
            case .movieCellDownloadTapped(let title):
                self?.downloadMovie(title: title)
            }
        }).disposed(by: disposeBag)
    }
    
    func requestMovieSection(type: Sections) {
        
    }
    
    func requestPreviewMovie(title: Title) {
        guard let titleName = title.original_title ?? title.original_name,
              let titleOverview = title.overview else { return }
        
        APICaller.shared.getMovieRx(with: titleName + " trailer")
//        throttle 실패, bind시켜줘야 할듯
//            .throttle(.seconds(3), latest: false, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self] videoElement in
                let movieDetail = MovieDetail(title: titleName, youtubeView: videoElement, titleOverview: titleOverview)
                self?.output.accept(.displayMovieDetail(movie: movieDetail))
            }).disposed(by: disposeBag)
    }
    
    func downloadMovie(title: Title) {
        let status: Bool
        do {
            status = try DataPersistenceManager.shared.downloadTitleWith(model: title)
            if status  {
                NotificationCenter.default.post(name: NSNotification.Name("downloaded"), object: nil)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

