//
//  CollectionViewTableViewCell.swift
//  Netflix
//
//  Created by yudonlee on 2022/07/03.
//

import UIKit

protocol CollectionViewTableViewCellDelegate: AnyObject {
    func collectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: TitlePreviewViewModel)
}
 
class CollectionViewTableViewCell: UITableViewCell {
    
    static let identifier = "CollectionViewTableCell"
    
    weak var delegate: CollectionViewTableViewCellDelegate?
    
    private var titles: [Title] = [Title]()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 140, height: 200)
        layout.scrollDirection = .horizontal
//        왜 zero를 해주는걸까?
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")
        
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemPink
        contentView.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    이걸 하지 않으니 layout이 뜨지 않음(CollectioNView가 작동하지 않음 why?
//    https://developer.apple.com/documentation/uikit/uiview/1622482-layoutsubviews
//    서브 클래스에서 해당 메소드를 오버라이드 하는데, 이는 subview layout의 정확성을 위해서이다. 이때 섭뷰의 오토 리사이징과 constraint-based가 너가 원하는 동작을 제공하지 못할경우에만 해당 메서드를 오버라이드 해야한다. 니 섭뷰에 프레임 사각형을 직접적으로 구현하는데 사용할수도 있다. 하지만 이 메서드를 직접 호출해서는 안된다. 만약 레이아웃 업데이트를 강제할껏이라면 다음 drawing update전에 수행하는 setneedsLayout을 해라.
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    func configure(with titles: [Title]) {
        self.titles = titles.filter { title in
            title.poster_path != nil
        }
//        main thread에서 reload해야하기 때문에, async를 해주었다.
        
        DispatchQueue.main.async {
            [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    private func downloadTitleAt(indexPath: IndexPath) {
        
        DataPersistenceManager.shared.downloadTitleWith(model: titles[indexPath.row]) { result in
            switch result {
            case .success():
                NotificationCenter.default.post(name: NSNotification.Name("downloaded"), object: nil)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension CollectionViewTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
//      poster path가 empty시 빈 UICollectionViewCell을 리턴해주도록 해 crash 방지
        guard let model = titles[indexPath.row].poster_path else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath)
        }
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else {
            return
        }
        
        APICaller.shared.getMovie(with: titleName + " trailer") { [weak self] result in
            switch result {
            case .success(let videoElement):
                
                let title = self?.titles[indexPath.row]
                guard let titleOverview = title?.overview else {
                    return
                }
                
                guard let strongSelf = self else {
                    return
                }
                let viewModel = TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: titleOverview)
                self?.delegate?.collectionViewTableViewCellDidTapCell(strongSelf, viewModel: viewModel)
                print(videoElement.id)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let downloadAction = UIAction(title: "Download", subtitle: nil, image: nil, identifier: nil, discoverabilityTitle: nil , state: .off) { _ in
                self?.downloadTitleAt(indexPath: indexPath)
            }
            return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [downloadAction])
        }
        
        return config
    }
}
