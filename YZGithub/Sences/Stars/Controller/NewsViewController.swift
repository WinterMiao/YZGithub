//
//  NewsViewController.swift
//  YZGithub
//
//  Created by 郑建文 on 16/8/24.
//  Copyright © 2016年 Zheng. All rights reserved.
//

import UIKit
import MBProgressHUD
import JLSwiftRouter

class NewsViewController: BaseTableViewController<Event> {


    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "动态"
    }
    override func fetchData(success:()->()) {
        if page == -1 {
            GlobalHubHelper.showError("没有数据了", view: self.view)
        }
        let hub = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hub.labelText = "网络请求中..."
        Provider.sharedProvider.request(GitHubAPI.UserEvent(username: UserInfoHelper.sharedInstance.user!.login!, page: page)) { (result) in
            switch result {
            case .Success(let response):
                do {
                    let array = try response.mapArray(Event)
                    if self.page == 1 {
                        self.dataArray = array
                    }else {
                        self.dataArray?.appendContentsOf(array)
                    }
                    if let nextpage = response.pageNumberWithType(PageType.next) { 
                        self.page = nextpage 
                    }else {
                        self.page = -1
                    }
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                }catch{
                    GlobalHubHelper.showError("数据解析失败", view: self.view)
                }
            case .Failure(let error):
                GlobalHubHelper.showError("网络请求失败:\(error)", view: self.view)
            }
            if self.ifloading == IfloadMore.loading {
                self.ifloading.change()
                success()
            }
        }
    }
}