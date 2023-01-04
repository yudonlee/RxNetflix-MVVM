//
//  HomeViewModel.swift
//  Netflix
//
//  Created by 이유돈 on 2023/01/02.
//

import Foundation
import OSLog

import RxSwift
import RxCocoa

protocol ViewModel {
    associatedtype Input
    associatedtype Output
}

enum APICall: Error {
    case isTitleEmpty
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
        case viewWillAppear
    }
    
    enum Output {
        //        case movieDataLoaded(titles: [Title])
        case displayMovieDetail(movie: MovieDetail)
        case thumbnail(previewMovie: PreviewMovie)
    }
    
    init() {
        bind()
    }
    func bind() {
        _ = eventUI.subscribe(onNext: { [weak self] event in
            switch event {
            case .requestMovieData(let section):
                break
            case .downloadButtonTapped(let title):
                self?.downloadMovie(title: title)
            case .movieCellTapped(let title):
                self?.movieDetail(title: title)
            case .movieCellDownloadTapped(let title):
                self?.downloadMovie(title: title)
            case .viewWillAppear:
                self?.randomMovie()
            }
        }).disposed(by: disposeBag)
    }
    
    func randomMovie() {
        APICaller.shared.getTrendingTvsRx()
            .map { titles in
                if let selectedTitle = titles.randomElement(),
                   let titleName = selectedTitle.original_title ?? selectedTitle.original_name,
                   let posterURL = selectedTitle.poster_path {
                    return PreviewMovie(titleName: titleName, posterURL: posterURL)
                } else {
                    return PreviewMovie(titleName: "", posterURL: "")
                }
            }
            .withUnretained(self)
            .subscribe { viewModel, previewMovie in
                viewModel.output.accept(.thumbnail(previewMovie: previewMovie))
            } onError: { error in
                os_log(.error, "영화정보를 불러오지 못했어요")
            }
        
    }
    
    func requestMovieDetail(title: Title) -> Observable<MovieDetail> {
        guard let titleName = title.original_title ?? title.original_name,
              let titleOverview = title.overview else {
            return Observable.create { emitter in
                emitter.onError(APICall.isTitleEmpty)
                return Disposables.create()
            }
        }
        return APICaller.shared.getMovieRx(with: titleName + " trailer")
            .map { MovieDetail(title: titleName, youtubeView: $0, titleOverview: titleOverview) }
    }
    
    func movieDetail(title: Title) {
        requestMovieDetail(title: title)
            .withUnretained(self)
            .subscribe { viewModel, movieDetail in
                viewModel.output.accept(.displayMovieDetail(movie: movieDetail))
            } onError: { error in
                os_log(.error, "MovieData를 로드하지 못했습니다.")
            }.disposed(by: disposeBag)
    }
    
    func requestMovieSection(type: Sections) {
        
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

