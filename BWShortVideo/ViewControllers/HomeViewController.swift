//
//  HomeViewController.swift
//  BWShortVideo
//
//  Created by bairdweng on 2020/9/23.
//

import Async
import SnapKit
import UIKit
class HomeViewController: UIViewController {
    let cell_id = "home_cell_id"

    private var cellHeight = CGFloat(0)
    @objc dynamic var currentIndex = 0
    lazy var tableView: UITableView = { [weak self] in
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isPagingEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.register(DataTableViewCell.self, forCellReuseIdentifier: cell_id)
        return tableView
    }()

    lazy var dataSource: [String] = {
        var dataSource: [String] = [
            "https://v-cdn.zjol.com.cn/280443.mp4",
            "https://v-cdn.zjol.com.cn/276982.mp4",
            "https://v-cdn.zjol.com.cn/276984.mp4",
            "https://v-cdn.zjol.com.cn/276985.mp4",
            "https://v-cdn.zjol.com.cn/276986.mp4",
            "https://v-cdn.zjol.com.cn/276987.mp4",
            "https://v-cdn.zjol.com.cn/276988.mp4",
            "https://v-cdn.zjol.com.cn/276989.mp4",
        ]
        return dataSource
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cellHeight = view.frame.height
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
            // Fallback on earlier versions
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        // kvo
        addObserver(self, forKeyPath: "currentIndex", options: [.old, .new], context: nil)

        Async.main(after: 1) {
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DataTableViewCell
            cell.playerView.play()
        }
        // Do any additional setup after loading the view.
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
//        if keyPath == "currentIndex" {
//            let cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0)) as! DataTableViewCell
//            cell.playerView.play()
//            print("currentIndex======\(currentIndex)")
//        }
//        super.observeValue(forKeyPath: keyPath, of: object, change: nil, context: nil)
//    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentIndex" {
            weak var cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0)) as? DataTableViewCell
            cell?.playerView.play()
            print("currentIndex======\(currentIndex)")
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cell_id, for: indexPath) as! DataTableViewCell
        cell.selectionStyle = .none
        cell.videUrl = dataSource[indexPath.row]
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool) {
        let transPoint = scrollView.panGestureRecognizer.translation(in: scrollView)
        if transPoint.y < -50, currentIndex < dataSource.count - 1 {
            currentIndex += 1
        }
        if transPoint.y > 50, currentIndex > 0 {
            currentIndex -= 1
        }
        print("==================\(currentIndex)")
    }
}
