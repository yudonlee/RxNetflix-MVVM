//
//  TitleCollectionViewCell.swift
//  Netflix
//
//  Created by yudonlee on 2022/07/10.
//

import UIKit
import Kingfisher
import SDWebImage

class TitleCollectionViewCell: UICollectionViewCell {

    static let identifier = "TitleCollectionViewCell"
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
//        비율이 어떻게 됐든간에 우리는 cell내부에 전체로 채울것이다
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        old layout 쓰기
        contentView.addSubview(posterImageView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        posterImageView.frame = contentView.bounds
    }
    
    public func configure(with model: String) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model)") else { return }
//        kingfihser가 메모리는 더 많이 쓰는듯 하다 200MB
        posterImageView.kf.setImage(with: url)
//      130MB
//        posterImageView.sd_setImage(with: url)
    }
    
}

