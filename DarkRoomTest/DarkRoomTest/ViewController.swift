//
//  ViewController.swift
//  DarkRoomTest
//
//  Created by 엑소더스이엔티 on 2023/10/11.
//

import Photos
import UIKit

private enum DarkRoomMediaType: Int {
    case singleImage = 1
    case multiImage = 2
    case singleVideo = 3
    case multiVideo = 4
    case mixedMedia = 5
}

enum MediaItem {
    case image(i: MediaImage)
    case video(v: MediaVideo)
}

struct MediaVideo {
    var video: PHAsset?
    var previewImage: UIImage?
    var url: URL?
    var previewUrl: URL?
}

struct MediaImage {
    var image: UIImage?
    var url: URL?
}

class ViewController: UIViewController {
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    var mediaItems: [MediaItem] = []
    var placeholderImage = UIImage(named: "img_splash_logo")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.button.addTarget(self, action: #selector(clickVideo), for: .touchUpInside)
        clickVideo()
    }
    
    @objc func clickImage() {
        mediaItems.removeAll()
        let temp1: MediaItem = .image(i: MediaImage(url: URL(string: "https://cxvavpevuyhk11458802.cdn.ntruss.com/51/f094f030-5af1-4bd8-a762-8fd95af7520d.webp?type=m&w=3000&h=3000")))
        let temp2: MediaItem = .image(i: MediaImage(url: URL(string: "https://cxvavpevuyhk11458802.cdn.ntruss.com/51/713be62c-ceef-4caa-bb5e-a2a3db5aef9d.webp?type=m&w=3000&h=3000")))
        let temp3: MediaItem = .image(i: MediaImage(url: URL(string: "https://cxvavpevuyhk11458802.cdn.ntruss.com/51/5b9f2fec-5ff5-48ef-adb7-55ce1d854fce.webp?type=m&w=3000&h=3000")))
        
        mediaItems.append(temp1)
        mediaItems.append(temp2)
        mediaItems.append(temp3)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let carauselController = DarkRoomCarouselViewController(imageDataSource: self, imageDelegate: self, imageLoader: ImageLoaderImpl(), initialIndex: 0, configuration: DarkRoomCarouselDefaultConfiguration(), type: DarkRoomMediaType.multiImage.rawValue, nickname: "agfggg", timeString: "2023. 08. 29(화) 오후 03:46", imageUrl: "https://cxvavpevuyhk11458802.cdn.ntruss.com/51/f094f030-5af1-4bd8-a762-8fd95af7520d.webp?type=m&w=3000&h=3000")
            self.present(carauselController, animated: true)
        }
    }
    
    @objc func clickVideo() {
        mediaItems.removeAll()
        
        let temp1: MediaItem = .video(v: MediaVideo(previewImage: imageview.image, url: URL(string: "https://toyqpwomxocl10099041.cdn.ntruss.com/hls/rOTgulfvoh0kzep2HPMteQ__/1201/d9be2b40-828c-4a38-b038-2914e0de7278,,_SD_480,_HD_720,_FHD_1080,.mp4.smil/master.m3u8"), previewUrl: URL(string: "https://cxvavpevuyhk11458802.cdn.ntruss.com/51/5b9f2fec-5ff5-48ef-adb7-55ce1d854fce.webp?type=m&w=3000&h=3000")))
        
        mediaItems.append(temp1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let carauselController = DarkRoomCarouselViewController(imageDataSource: self, imageDelegate: self, imageLoader: ImageLoaderImpl(), initialIndex: 0, configuration: DarkRoomCarouselDefaultConfiguration(), type: DarkRoomMediaType.singleVideo.rawValue, nickname: "agfggg", timeString: "2023. 08. 29(화) 오후 03:46", imageUrl: "https://cxvavpevuyhk11458802.cdn.ntruss.com/51/f094f030-5af1-4bd8-a762-8fd95af7520d.webp?type=m&w=3000&h=3000")
            self.present(carauselController, animated: true)
        }
    }
}

extension ViewController: DarkRoomCarouselDelegate {
    // 상세에서 스크롤 시 후속 작업.. 딱히 필요 없음
    func carousel(didSlideToIndex index: Int) {
    }
}

extension ViewController: DarkRoomCarouselDataSource {
    func assetData(at index: Int) -> DarkRoomCarouselData {
        switch mediaItems[index] {
        case .image(i: let i):
            if let imageUrl = i.url, let placeholderImage {
                let imageData = DarkRoomCarouselImageDataImpl(imageUrl: imageUrl, overlayURL: nil, imagePlaceholder: placeholderImage)
                return .image(data: imageData)
            }
            
            return .image(data: DarkRoomCarouselImageDataImpl(imageUrl: URL(string: "nil")!, overlayURL: nil, imagePlaceholder: UIImage()))
        
        case .video(v: let v):
            if let videoUrl = v.url, let placeholderImage {
                if let previewImageUrl = v.previewUrl {
                    let videoData = DarkRoomCarouselVideoDataImpl(videoImageUrl: previewImageUrl, videoUrl: videoUrl, overlayURL: nil, imagePlaceholder: placeholderImage)
                    return .video(data: videoData)
                }
            }
            
            return .video(data: DarkRoomCarouselVideoDataImpl(videoImageUrl: URL(string: "nil")!, videoUrl: URL(string: "nil")!, overlayURL: nil, imagePlaceholder: UIImage()))
        }
    }

    func numberOfAssets() -> Int {
        mediaItems.count
    }
    
    // 이미지 보여줄 때 애니메이션 적용될 원래 UIImageView
    func imageView(at index: Int) -> UIImageView? {
        imageview
    }
    
    // 동영상 보여줄 때 애니메이션 적용될 미리보기 UIImageView
    func overlayImageView(at index: Int) -> UIImageView? {
        imageview
    }
}

protocol ImageLoaderCancelable: AnyObject {
    func cancel()
}

class ImageLoaderImpl: DarkRoomImageLoader, ImageLoaderCancelable {
    var task: URLSessionDataTask?
    
    func loadImage(_ url: URL) -> UIImage? {
        guard url.isFileURL else { return nil }
        guard
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
        else { return nil }
        return image
    }
    
    func loadImage(_ url: URL, placeholder: UIImage?, imageView: UIImageView, completion: @escaping (UIImage?) -> Void) {
        if url.isFileURL {
            guard
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async { [weak imageView] in
                    imageView?.image = placeholder
                }
                return
            }
            DispatchQueue.main.async { [weak imageView] in
                imageView?.image = image
                completion(image)
            }
        } else {
            task = URLSession.shared.dataTask(with: url) { [weak imageView] data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                else {
                    DispatchQueue.main.async { [weak imageView] in
                        imageView?.image = placeholder
                    }
                    return
                    
                }
                DispatchQueue.main.async {
                    imageView?.image = image
                    completion(image)
                }
            }
            task?.resume()
        }
    }
    
    func cancel() {
        task?.cancel()
    }
}

extension Array where Element == ImageLoaderCancelable {
    func cancelAllImageLoading() {
        self.forEach { $0.cancel() }
    }
}

