//
//  YouTubeViewController.swift
//  DarkRoomTest
//
//  Created by 엑소더스이엔티 on 2023/10/20.
//

import UIKit
import YouTubePlayer

// SRT 파일을 파싱하여 저장할 struct
struct Subtitle {
    var sequenceNumber: Int
    var startTime: TimeInterval
    var endTime: TimeInterval
    var text: String
}

class YouTubeViewController: UIViewController {
    @IBOutlet var videoPlayer: YouTubePlayerView!
    @IBOutlet var tableView: UITableView!
    
    var subTitle: [Subtitle] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        "https://www.youtube.com/watch?v=Ga-UF1j7cQ4"
        addDelegate()
    }
    
    func addDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "SubTitleCell", bundle: nil), forCellReuseIdentifier: "SubTitleCell")
    }
}

extension YouTubeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubTitleCell", for: indexPath) as? SubTitleCell else { return UITableViewCell() }
        
        return cell
    }
}
