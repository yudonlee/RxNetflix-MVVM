//
//  HomeViewController.swift
//  Netflix
//
//  Created by yudonlee on 2022/07/03.
//

import UIKit

import RxSwift
import RxCocoa

enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTvs = 1
    case Popular = 2
    case Upcoming = 3
    case Toprated = 4
}

class HomeViewController: UIViewController {

    let sectionTitles: [String] = ["Trending Movies",  "Tending Tv", "Pouplar", "Upcoming Movie", "Top rated"]
    
    private var randomTrendingMovie: Title?
    private var headerView: HeroHeaderUIView?
    
    private var disposeBag = DisposeBag()
    
    
    private let viewModel = HomeViewModel()
    
    
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTable)
        
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        
        configureNavigationBar()
        configureTableHeaderView()
        bind()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.eventUI.accept(.viewWillAppear)
    }
    private func bind() {
        viewModel.output
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .displayMovieDetail(let movieDetail):
                    let vc = TitlePreviewViewController()
                    vc.configure(with: movieDetail)
                    self?.navigationController?.pushViewController(vc, animated: true)
                case .thumbnail(let previewMovie):
                    self?.headerView?.configure(with: previewMovie)
                }
            }).disposed(by: disposeBag)
    }
    
    private func configureTableHeaderView() {
        headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        homeFeedTable.tableHeaderView = headerView
    }
    
    private func configureNavigationBar() {
//        why not let? 60초후에 공개됩니다 우리가 더 수정해야할 부분이 존재하기 때문이다
//      image 내부 수정할 부분이 존재하는데, intrinsicCotentSize의 문제, 분명하게 설정하지 않으면 버튼의 넓이만큼 image가 expanding된다. 그렇기 때문에 intrinctContentSize의 property는 default로 height에 대해서는 설정되는데, width는 되지 않음. 
        var image = UIImage(named: "netflixLogo")
        image = image?.resizeTo(size: CGSize(width: 50, height: 35))
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
                                             UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil)]
        
        navigationController?.navigationBar.tintColor = .white
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
        //아직까진 값이 없기 때문에 아무 데이터가 존재하지 않는다.
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        switch indexPath.section {
        case Sections.TrendingMovies.rawValue:
            APICaller.shared.getTrendingMovies { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.TrendingTvs.rawValue:
            APICaller.shared.getTrendingTvsRx()
                .subscribe { event in
                    if case let .next(titles) = event {
                        cell.configure(with: titles)
                    }
                }.disposed(by: disposeBag)
        case Sections.Popular.rawValue:
            APICaller.shared.getPopularRx()
                .subscribe { event in
                    if case let .next(titles) = event {
                        cell.configure(with: titles)
                    }
                }.disposed(by: disposeBag)
        case Sections.Upcoming.rawValue:
            APICaller.shared.getUpcomingMoviesRx()
                .subscribe { event in
                    if case let .next(titles) = event {
                        cell.configure(with: titles)
                    }
                }.disposed(by: disposeBag)
        case Sections.Toprated.rawValue:
            APICaller.shared.getTopRatedRx()
                .subscribe { event in
                    if case let .next(titles) = event {
                        cell.configure(with: titles)
                    }
                }.disposed(by: disposeBag)
        default:
            return UITableViewCell()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {
            return
        }
//        deprecated될 예정
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .label
        
//        extension을 통해서 첫번째 문장만 Capitalized 시키는 방법
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    //NavigationBar가 scroll를 아래로 당기면 같이 올라감(navigation bar가 고정돼서 transparent하는것을 막아줌)
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}


extension HomeViewController: CollectionViewTableViewCellDelegate {
    func collectionViewMovieCellTapped(title: Title) {
        viewModel.eventUI.accept(.movieCellTapped(title: title))
    }
    
    func collectionViewMovieCellDownloadTapped(title: Title) {
        viewModel.eventUI.accept(.movieCellDownloadTapped(title: title))
    }
    
}


#if DEBUG
import SwiftUI
struct HomeViewControllerPreview: PreviewProvider {
    static var previews: some View {
        UINavigationController(rootViewController: HomeViewController())
            .toPreview()
    }
}
#endif

