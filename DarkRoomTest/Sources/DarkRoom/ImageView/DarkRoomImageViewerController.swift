//
//  DarkRoomImageViewerController.swift
//
//
//  Created by Kiarash Vosough on 7/31/22.
//
//  Copyright (c) 2022 Divar
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

internal final class DarkRoomImageViewerController: UIViewController, UIGestureRecognizerDelegate, DarkRoomMediaController {

    // MARK: - Transition Views

    internal var imageView: UIImageView = UIImageView(frame: .zero)
    
    internal var imageOverlayView: UIImageView? { nil }
    
    // MARK: - Views
    
    private var scrollView: UIScrollView!
    
    internal var backgroundView: UIView? {
        guard let parent = parent as? DarkRoomCarouselViewController else { return nil }
        return parent.backgroundView
    }
    

    internal var navBar: UIView? {
        guard let parent = parent as? DarkRoomCarouselViewController else { return nil }
        return parent.navBar
    }
    
    internal var infoView: MediaUserInfoView? {
        guard let parent = parent as? DarkRoomCarouselViewController else { return nil }
        return parent.infoView
    }
    
    private var top: NSLayoutConstraint!
    private var leading: NSLayoutConstraint!
    private var trailing: NSLayoutConstraint!
    private var bottom: NSLayoutConstraint!
    
    // MARK: - Variables

    private var lastLocation: CGPoint
    
    private var isAnimating: Bool
    
    private var maxZoomScale: CGFloat
    
    // MARK: - Inputs
    
    internal var index: Int
    
    private var imageURL: URL
    
    private var imagePlaceholder: UIImage
    
    private let imageLoader: DarkRoomImageLoader
    
    private var configuration: DarkRoomImageControllerConfiguration
    
    private var infoViewBottomLayout: NSLayoutConstraint!
    
    private var isShowingControls: Bool {
        didSet {
            guard oldValue != isShowingControls else { return }
            changeControlsVisibilty(with: oldValue)
        }
    }
    
    private var safeAreaTopPadding: CGFloat {
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top ?? 20
        
        return topPadding
    }
    
    private var safeAreaBottomPadding: CGFloat {
        let window = UIApplication.shared.windows.first
        let bottomPadding = window?.safeAreaInsets.bottom ?? 34
        
        return bottomPadding
    }
    
    // MARK: - LifeCycle

    internal init(
        index: Int = 0,
        imageURL: URL,
        imagePlaceholder: UIImage,
        imageLoader: DarkRoomImageLoader,
        configuration: DarkRoomImageControllerConfiguration = DarkRoomImageControllerDeafultConfiguration()
    ) {
        self.index = index
        self.imageURL = imageURL
        self.imageLoader = imageLoader
        self.imagePlaceholder = imagePlaceholder
        self.configuration = configuration
        self.lastLocation = .zero
        self.isAnimating = false
        self.maxZoomScale = 1.0
        self.isShowingControls = true
        super.init(nibName: nil, bundle: nil)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func loadView() {
        prepareView()
        prepareScrollView()
        prepareImageView()
    }
    
    private func prepareView() {
        let view = UIView()
        view.backgroundColor = configuration.backgrountColor
        self.view = view
    }
    
    private func prepareScrollView() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        scrollView.bindFrameToSuperview()
        scrollView.backgroundColor = .clear
        scrollView.addSubview(imageView)
    }
    
    private func prepareImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        top = imageView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        leading = imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        trailing = scrollView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        bottom = scrollView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)

        NSLayoutConstraint.activate([
            top,
            leading,
            trailing,
            bottom
        ])
    }

    internal override func viewDidLoad() {
        super.viewDidLoad()
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        loadImage()
        
        addGestureRecognizers()
    }
    
    private func loadImage() {
        imageLoader.loadImage(imageURL, placeholder: imagePlaceholder, imageView: imageView) { image in
            DispatchQueue.main.async { [weak self] in
                self?.layout()
            }
        }
    }
    
    internal override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layout()
    }
    
    private func layout() {
        updateConstraintsForSize(view.bounds.size)
        updateMinMaxZoomScaleForSize(view.bounds.size)
    }
    
    internal func prepareForDismiss() {}
    
    // MARK: Gesture Recognizers

    private func addGestureRecognizers() {
        
        let panGesture = UIPanGestureRecognizer(
            target: self, action: #selector(didPan(_:))
        )
        panGesture.cancelsTouchesInView = false
        panGesture.delegate = self
        scrollView.addGestureRecognizer(panGesture)
        
        let pinchRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(didPinch(_:))
        )
        pinchRecognizer.numberOfTapsRequired = 1
        pinchRecognizer.numberOfTouchesRequired = 2
        scrollView.addGestureRecognizer(pinchRecognizer)
        
        let singleTapGesture = UITapGestureRecognizer(
            target: self, action: #selector(didSingleTap(_:))
        )
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(singleTapGesture)
        
        let doubleTapRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(didDoubleTap(_:))
        )
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        singleTapGesture.require(toFail: doubleTapRecognizer)
    }
    
    @objc
    private func didPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard
            isAnimating == false,
            scrollView.zoomScale == scrollView.minimumZoomScale
        else { return }
        
        let container:UIView! = imageView
        if gestureRecognizer.state == .began {
            lastLocation = container.center
        }
        
        if gestureRecognizer.state != .cancelled {
            let translation: CGPoint = gestureRecognizer
                .translation(in: view)
            container.center = CGPoint(
                x: lastLocation.x + translation.x,
                y: lastLocation.y + translation.y)
        }
        
        let diffY = view.center.y - container.center.y
        backgroundView?.alpha = 1.0 - abs(diffY/view.center.y)
        if gestureRecognizer.state == .ended {
            if abs(diffY) > configuration.dismissPanAmount {
                dismiss(animated: true)
            } else {
                executeCancelAnimation()
            }
        }
    }
    
    @objc
    private func didPinch(_ recognizer: UITapGestureRecognizer) {
        var newZoomScale = scrollView.zoomScale / 1.5
        newZoomScale = max(newZoomScale, scrollView.minimumZoomScale)
        scrollView.setZoomScale(newZoomScale, animated: true)
    }
    
    @objc
    private func didSingleTap(_ recognizer: UITapGestureRecognizer) {
        self.isShowingControls.toggle()
    }
    
    private func changeControlsVisibilty(with isShowingControls: Bool) {
        UIView.animate(withDuration: 0.235, delay: 0, options: [.curveEaseInOut]) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.updateAlpha()
        }
    }
    
    private func updateAlpha() {
        let currentNavAlpha = self.navBar?.alpha ?? 0.0
        let willAlpha = currentNavAlpha > 0.5 ? 0.0 : 1.0
        self.navBar?.alpha = willAlpha
        self.infoView?.alpha = willAlpha
    }
    
    @objc
    private func didDoubleTap(_ recognizer:UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: imageView)
        zoomInOrOut(at: pointInView)
    }
    
    internal func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard scrollView.zoomScale == scrollView.minimumZoomScale,
              let panGesture = gestureRecognizer as? UIPanGestureRecognizer
        else { return false }
        
        let velocity = panGesture.velocity(in: scrollView)
        return abs(velocity.y) > abs(velocity.x)
    }
}

// MARK: Adjusting the dimensions

extension DarkRoomImageViewerController {
    
    fileprivate func updateMinMaxZoomScaleForSize(_ size: CGSize) {
        let targetSize = imageView.bounds.size
        if targetSize.width == 0 || targetSize.height == 0 {
            return
        }
        
        let minScale = min(
            size.width/targetSize.width,
            size.height/targetSize.height)
        let maxScale = max(
            (size.width + 1.0) / targetSize.width,
            (size.height + 1.0) / targetSize.height)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        maxZoomScale = maxScale
        scrollView.maximumZoomScale = maxZoomScale * 1.1
    }
    
    
    fileprivate func zoomInOrOut(at point:CGPoint) {
        let newZoomScale = scrollView.zoomScale == scrollView.minimumZoomScale
        ? maxZoomScale : scrollView.minimumZoomScale
        let size = scrollView.bounds.size
        let w = size.width / newZoomScale
        let h = size.height / newZoomScale
        let x = point.x - (w * 0.5)
        let y = point.y - (h * 0.5)
        let rect = CGRect(x: x, y: y, width: w, height: h)
        scrollView.zoom(to: rect, animated: true)
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        top.constant = yOffset
        bottom.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        leading.constant = xOffset
        trailing.constant = xOffset
        view.layoutIfNeeded()
    }
}

// MARK: Animation

extension DarkRoomImageViewerController {
    
    private func executeCancelAnimation() {
        self.isAnimating = true
        UIView.animate(withDuration: 0.237, animations: {
            self.imageView.center = self.view.center
            self.backgroundView?.alpha = 1.0
        }) { [weak self] _ in
            self?.isAnimating = false
        }
    }
}

// MARK: - UIScrollViewDelegate

extension DarkRoomImageViewerController: UIScrollViewDelegate {

    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    internal func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
}

