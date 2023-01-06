//
//  HomeViewController.swift
//  Netflix
//
//  Created by yudonlee on 2022/07/03.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTvs = 1
    case Popular = 2
    case Upcoming = 3
    case Toprated = 4
}

struct MovieCcell {
    var titles: [Title]
}

struct SectionOfMovieCell {
    var header: String
    var items: [Item]
}

extension SectionOfMovieCell: SectionModelType {
    typealias Item = MovieCcell
    
    init(original: SectionOfMovieCell, items: [Item]) {
        self = original
        self.items = items
    }
}

class HomeViewController: UIViewController {

    let sectionTitles: [String] = ["Trending Movies",  "Tending Tv", "Pouplar", "Upcoming Movie", "Top rated"]
    
    private var randomTrendingMovie: Title?
    private var headerView: HeroHeaderUIView?
    
    private var disposeBag = DisposeBag()
    
    private let viewModel = HomeViewModel()
    
    private var data = BehaviorRelay<[[Title]]>(value: [])
    
    
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
//        homeFeedTable.dataSource = self
        
        configureNavigationBar()
        configureTableHeaderView()
        dataSourceToTableView()
        bind()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.eventUI.accept(.viewWillAppear)
    }
    
    private func dataSourceToTableView() {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfMovieCell>(
            configureCell: { dataSource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else { return UITableViewCell() }
                
                cell.delegate = self
                cell.configure(with: item.titles)
                return cell
            })
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
        
        data
            .withUnretained(self)
            .map { vc, values in values.enumerated().map { index, value in return SectionOfMovieCell(header: vc.sectionTitles[index], items: [MovieCcell(titles: value)]) } }
            .bind(to: homeFeedTable.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        viewModel.eventUI.accept(.requestAllMovies)
        viewModel.output
            .withUnretained(self)
            .subscribe(onNext: { currentVC, event in
                switch event {
                case .displayMovieDetail(let movieDetail):
                    DispatchQueue.main.async {
                        let vc = TitlePreviewViewController()
                        vc.configure(with: movieDetail)
                        currentVC.navigationController?.pushViewController(vc, animated: true)
                    }
                case .thumbnail(let previewMovie):
                    currentVC.headerView?.configure(with: previewMovie)
                case .allMovies(let movieTitles):
                    currentVC.data.accept(movieTitles)
                }
            }).disposed(by: disposeBag)
    }
    
    private func configureTableHeaderView() {
        headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        homeFeedTable.tableHeaderView = headerView
    }
    
    private func configureNavigationBar() {
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

extension HomeViewController: UITableViewDelegate {
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

