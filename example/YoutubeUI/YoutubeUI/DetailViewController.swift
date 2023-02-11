//
//  DetailViewController.swift
//  YoutubeUI
//
//  Created by Daniel on 2023/02/11.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var tags: UILabel!
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var detailDescription: UILabel!
    @IBOutlet weak var channelName: UILabel!
    var videos = [Video]()
    var video: Video!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tags.text = video.tag
        detailTitle.text = video.title
        detailDescription.text = video.detailDescription
        channelName.text = video.channel
        let urlRequest : URLRequest = URLRequest(url: video.video_url)
        webView.load(urlRequest)
        
    }
    
    func loadData() {
        guard let jsonURL = Bundle.main.url(forResource: "videos", withExtension: "json"), let data = try? Data(contentsOf: jsonURL) else {
            print("videos")
            return
        }
        
        DispatchQueue.main.async {
            do {
                self.videos = try JSONDecoder().decode([Video].self, from: data)
                self.tableView.rowHeight = 310
                self.tableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailTableViewCell
        let row = videos[indexPath.row]
        cell.prepare(video: row)
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
