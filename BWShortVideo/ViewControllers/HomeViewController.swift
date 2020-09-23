//
//  HomeViewController.swift
//  BWShortVideo
//
//  Created by bairdweng on 2020/9/23.
//

import UIKit
import SnapKit
class HomeViewController: UIViewController {
    let cell_id = "home_cell_id"
    lazy var tableView:UITableView = { [weak self] in
        let tableView = UITableView()
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Do any additional setup after loading the view.
    }
    func basePlayerExample() {
        let playerView = BWAVPlayerView()
        self.view.addSubview(playerView)
        playerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        playerView.playerUrl = "https://aweme.snssdk.com/aweme/v1/play/?video_id=v0200ff70000bck86n4mavf9lsqsr7m0&line=0&ratio=720p&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0"
        BWAVPlayerManage.shareManage.play(player: playerView.player)
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
extension HomeViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cell_id, for: indexPath)
        return cell
    }
    
    
}
