//
//  MediaUserInfoView.swift
//  
//
//  Created by 엑소더스이엔티 on 2023/07/19.
//

import UIKit

private enum DarkRoomMediaType: Int {
    case singleImage = 1
    case multiImage = 2
    case singleVideo = 3
    case multiVideo = 4
    case mixedMedia = 5
}

class MediaUserInfoView: UIView {
    // MARK: - Views
    
    private let stackview = UIStackView()
    private let type: DarkRoomMediaType
    private var userInfo: DarkRoomMediaUserInfo?
    private var imageLoader: DarkRoomImageLoader?
    
    // MARK: - LifeCycle
    
    internal init(userInfo: DarkRoomMediaUserInfo, imageLoader: DarkRoomImageLoader, type: Int) {
        self.userInfo = userInfo
        self.imageLoader = imageLoader
        self.type = DarkRoomMediaType(rawValue: type) ?? .mixedMedia
        super.init(frame: .zero)
        prepare()
    }

    internal required init?(coder: NSCoder) {
        self.type = .mixedMedia
        super.init(coder: coder)
        prepare()
    }
    
    private func prepare() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.semanticContentAttribute = .forceLeftToRight
        prepareBackgroundView()
        prepareViews()
    }
    
    private func prepareBackgroundView() {
        let darkBackground = UIView()
        darkBackground.translatesAutoresizingMaskIntoConstraints = false
        darkBackground.backgroundColor = .black
        darkBackground.alpha = 0.7
        addSubview(darkBackground)
        
        NSLayoutConstraint.activate([
            darkBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            darkBackground.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            darkBackground.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            darkBackground.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
    
    private func prepareViews() {
        guard let userInfo,
              let imageLoader,
              let url = URL(string: userInfo.imageUrl) else { return }
        let profile = UIImageView(frame: CGRect(x: 16, y: 16, width: 40, height: 40))
        imageLoader.loadImage(url, placeholder: nil, imageView: profile) { image in
            profile.image = image
        }
        
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textAlignment = .left
        name.numberOfLines = 1
        name.textColor = .white
        name.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        name.text = userInfo.nickname
        
        let verifiedIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 13))
        verifiedIcon.translatesAutoresizingMaskIntoConstraints = false
        verifiedIcon.image = UIImage(named: "icon_verified_badge_small")
        
        var iconImage: UIImage?
        switch type {
        case .singleImage, .multiVideo, .mixedMedia:
            break
        case .multiImage:
            iconImage = UIImage(named: "icon_multi-select_photo_18px")
        case .singleVideo:
            iconImage = UIImage(named: "icon_video_photo_18px")
        }
        
        let mediaIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        mediaIcon.translatesAutoresizingMaskIntoConstraints = false
        mediaIcon.image = iconImage
        
        let time = UILabel()
        time.translatesAutoresizingMaskIntoConstraints = false
        time.textAlignment = .left
        time.numberOfLines = 1
        time.textColor = .white
        time.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        time.text = userInfo.timeString
        
        addSubview(profile)
        addSubview(name)
        addSubview(verifiedIcon)
        addSubview(mediaIcon)
        addSubview(time)
        
        NSLayoutConstraint.activate([
            profile.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            profile.centerYAnchor.constraint(equalTo: centerYAnchor),
            profile.widthAnchor.constraint(equalToConstant: 40),
            profile.heightAnchor.constraint(equalToConstant: 40),
            name.topAnchor.constraint(equalTo: profile.topAnchor, constant: 3),
            name.leadingAnchor.constraint(equalTo: profile.trailingAnchor, constant: 8),
            verifiedIcon.centerYAnchor.constraint(equalTo: name.centerYAnchor),
            verifiedIcon.leadingAnchor.constraint(equalTo: name.trailingAnchor, constant: 2),
            verifiedIcon.widthAnchor.constraint(equalToConstant: 12),
            verifiedIcon.heightAnchor.constraint(equalToConstant: 13),
            mediaIcon.centerYAnchor.constraint(equalTo: name.centerYAnchor),
            mediaIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            mediaIcon.widthAnchor.constraint(equalToConstant: 18),
            mediaIcon.heightAnchor.constraint(equalToConstant: 18),
            time.bottomAnchor.constraint(equalTo: profile.bottomAnchor, constant: -1),
            time.leadingAnchor.constraint(equalTo: profile.trailingAnchor, constant: 8)
        ])
        
        profile.layer.cornerRadius = 8
        profile.layer.masksToBounds = true
    }
}
