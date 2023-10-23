//
//  YouTubeViewController.swift
//  DarkRoomTest
//
//  Created by 엑소더스이엔티 on 2023/10/20.
//

import UIKit
import YouTubePlayer

// SRT 파일을 파싱하여 저장할 struct
struct Subtitle: Equatable {
    var sequenceNumber: Int
    var startTime: TimeInterval
    var endTime: TimeInterval
    var text: String
}

class YouTubeViewController: UIViewController {
    private let apiKey = "AIzaSyBFpdepJS7NBv4dP_eyKBriH-VVjO1_AS4"
    @IBOutlet var videoPlayer: YouTubePlayerView!
    @IBOutlet var tableView: UITableView!
    
    var timer: Timer? = nil
    let videoId: String
    var subTitle: [Subtitle] = []
    var currentSubtitleIndex = 0
    
    init(videoId: String) {
        self.videoId = videoId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        "https://www.youtube.com/watch?v=Ga-UF1j7cQ4"
        addDelegate()
        startVideo()
        loadSubTitle()
        requestSubtitles()
    }
    
    func addDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "SubTitleCell", bundle: nil), forCellReuseIdentifier: "SubTitleCell")
        
        videoPlayer.delegate = self
    }
    
    private func startVideo() {
        videoPlayer.loadVideoID(videoId)
//        videoPlayer.getCurrentTime { time in
//            guard let time = time else { return }
//            print("time : \(time)")
//        }
//
//        videoPlayer.getDuration { duration in
//            guard let duration = duration else { return }
//            print("duration : \(duration)")
//        }
    }
    
    private func requestSubtitles() {
        let basicPath = "https://www.googleapis.com/youtube/v3/captions"
        let queryArray = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "videoId", value: videoId),
            URLQueryItem(name: "key", value: apiKey)
        ]
        let requestPath = makeApiPath(path: basicPath, queryArray: queryArray)
        guard let url = URL(string: requestPath) else { return }
        requestApi(path: url)
    }
    
    private func requestApi(path: URL) {
        var request = URLRequest(url: path)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error:", error ?? "Unknown error")
                return
            }

            // 여기서 응답 처리
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(jsonResponse)
                }
            } catch {
                print("JSON decoding error:", error)
            }
        }

        task.resume()
    }
    
    private func loadSubTitle() {
        // 리소스 파일 URL 확인
        guard let url = Bundle.main.url(forResource: "\(videoId)_kr", withExtension: "srt") else {
            print("오류: 파일을 찾을 수 없습니다.")
            return
        }
        
        // 파일 읽기 시도
        if let srt = try? String(contentsOf: url, encoding: .utf8) {
            let lines = srt.components(separatedBy: .newlines).filter { !$0.isEmpty }
            var subtitles: [Subtitle] = []
            
            var index = 0
            while index < lines.count {
                // 시간 코드 (--> 포함) 찾기
                if lines[index].contains("-->") {
                    let timeComponents = lines[index].components(separatedBy: .whitespaces)
                    
                    // 시간 코드 변환 시도
                    if timeComponents.count >= 3,
                       let startTimeInterval = convertToTimeInterval(from: timeComponents[0]),
                       let endTimeInterval = convertToTimeInterval(from: timeComponents[2]) {
                        
                        let text = lines[index + 1]
                        let subtitle = Subtitle(sequenceNumber: 0, startTime: startTimeInterval, endTime: endTimeInterval, text: text)
                        subtitles.append(subtitle)
                        index += 2
                    } else {
                        index += 1
                    }
                } else {
                    index += 1
                }
            }
            
            subTitle = subtitles
            tableView.reloadData()
        } else {
            print("오류: 파일을 읽을 수 없습니다.")
        }
    }

    private func convertToTimeInterval(from timeString: String) -> TimeInterval? {
        // 시간 형식 분할 (예: 00:02:17,280)
        let components = timeString.components(separatedBy: ":")
        guard components.count == 3,
           let hours = Int(components[0]),
           let minutes = Int(components[1]) else {
            return nil
        }
        
        let secondsAndMillis = components[2].components(separatedBy: ",")
        
        guard secondsAndMillis.count == 2,
              let seconds = Int(secondsAndMillis[0]),
              let milliseconds = Int(secondsAndMillis[1]) else { return nil }
        
        // TimeInterval로 변환
        let timeInterval = TimeInterval(hours * 3600 + minutes * 60 + seconds) + TimeInterval(milliseconds) / 1000.0
        return timeInterval
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = nil
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            // 현재 재생 시간에 해당하는 시간을 가지고 와서 자막을 찾아 볼드 처리하고 상단으로 스크롤 한다.
            self.videoPlayer.getCurrentTime { time in
                guard let time = time else { return }
                let filtered = self.subTitle.filter { $0.startTime <= time && $0.endTime >= time }
                if let first = filtered.first {
                    let index = self.subTitle.firstIndex(of: first)
                    let indexPath = IndexPath(row: index ?? 0, section: 0)
                    if self.currentSubtitleIndex != index {
                        let oldIndexPath = IndexPath(row: self.currentSubtitleIndex, section: 0)
                        self.currentSubtitleIndex = index ?? 0
                        
                        self.tableView.reloadRows(at: [indexPath, oldIndexPath], with: .automatic)
                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                }
            }
        }
    }

    func makeApiPath(path: String, queryArray: [URLQueryItem]) -> String {
        var components = URLComponents(string: path)
        components?.queryItems = queryArray
        if let finalPath = components?.url?.absoluteString {
            return finalPath
        } else {
            return path
        }
    }
}

extension YouTubeViewController: YouTubePlayerDelegate {
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        videoPlayer.play()
        startTimer()
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        var state = ""
        switch playerState {
        case .Unstarted:
            state = "Unstarted"
        case .Ended:
            state = "Ended"
        case .Playing:
            state = "Playing"
            startTimer()
        case .Paused:
            state = "Paused"
            timer?.invalidate()
        case .Buffering:
            state = "Buffering"
            timer?.invalidate()
        case .Queued:
            state = "Queued"
        }
        print("playerStateChanged: \(state)")
    }
    
    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        //
    }
}

extension YouTubeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubTitleCell", for: indexPath) as? SubTitleCell else { return UITableViewCell() }
        let data = subTitle[indexPath.row]
        cell.subTitleLabel.text = data.text
        cell.subTitleLabel.textColor = .black
        if indexPath.row == currentSubtitleIndex {
            cell.subTitleLabel.textColor = .red
        } else {
            cell.subTitleLabel.textColor = .black
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = subTitle[indexPath.row]
        let startTime = Float(data.startTime)
        videoPlayer.seekTo(startTime, seekAhead: true)
    }
}
