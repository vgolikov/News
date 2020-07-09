//
//  NewsViewController.swift
//  News
//
//  Created by Viachaslau Holikau on 7/9/20.
//  Copyright © 2020 Viachaslau Holikau. All rights reserved.
//

import UIKit
import KRProgressHUD
import Keyboardy

class NewsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var bottomUpdateView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var refreshControl = UIRefreshControl()
    var networkManager = NetworkManager.shared
    
    let cellReuseIdentifier = "NewsTableViewCell"
    
    var news = [News]()
    var filteredNews = [News]()
    
    var previousDate = Date()
    var isLoading = false
    
    var queryString = ""
    
    var isFiltering: Bool {
        return !queryString.isEmpty
    }
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "NewsTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.keyboardDismissMode = .onDrag
        
        fetchNews(date: Date())
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForKeyboardNotifications(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unregisterFromKeyboardNotifications()
    }
    
    func fetchNews(date: Date) {
        let dateString = formatter.string(from: date)
        KRProgressHUD.showOn(self).show()
        networkManager.getNews(fromDate: dateString, toDate: dateString) { [weak self] (news, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let self = self else { return }
                self.news = news
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    KRProgressHUD.dismiss()
                }
            }
        }
    }
    
    func setupRefreshControl() {
        refreshControl.backgroundColor = tableView.backgroundColor
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        previousDate = Date()
        fetchNews(date: Date())
    }
    
    func loadMoreNews() {
        isLoading = true
        
        previousDate = Calendar.current.date(byAdding: .day, value: -1, to: previousDate)!
        let previousDateString = formatter.string(from: previousDate)
        
        networkManager.getNews(fromDate: previousDateString, toDate: previousDateString) { [weak self] (news, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let self = self else { return }
                self.news.append(contentsOf: news)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func modifyInsets(keyboardHeight: CGFloat) {
        var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        insets.bottom = keyboardHeight
        tableView.contentInset = insets
    }
    
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
          return filteredNews.count
        }
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? NewsTableViewCell else { return UITableViewCell() }
        
        let news: News
        
        if isFiltering {
          news = filteredNews[indexPath.row]
        } else {
          news = self.news[indexPath.row]
        }
        
        cell.setupCell(news: news)
        cell.selectionStyle = .none
        
        return cell
    }
    
}


// MARK: - UIScrollViewDelegate
extension NewsViewController: UIScrollViewDelegate {
    // MARK: - Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
                
        let todayDateString = formatter.string(from: Date())
        let previousDateString = formatter.string(from: previousDate)
        
        let seventhDayBeforeToday = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
        
        if previousDate > seventhDayBeforeToday || todayDateString == previousDateString {
            if maximumOffset - currentOffset <= 10 {
                if !isLoading {
                    bottomUpdateView.isHidden = false
                    activityIndicator.isHidden = false
                    activityIndicator.startAnimating()
                    loadMoreNews()
                }
            }
        }
    }
}


// MARK: - UISearchBarDelegate
extension NewsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        queryString = searchText.trimmingCharacters(in: .whitespaces)
        
        if !searchText.isEmpty {
            filteredNews = news.filter { ($0.title?.lowercased().contains(queryString.lowercased()) ?? false) }
        }

        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


// MARK: - KeyboardStateDelegate
extension NewsViewController: KeyboardStateDelegate {
    func keyboardWillTransition(_ state: KeyboardState) {
        // keyboard will show or hide
        switch state {
        case .activeWithHeight(let height):
            modifyInsets(keyboardHeight: height)
        case .hidden:
            modifyInsets(keyboardHeight: 0)
        }
        
        view.layoutIfNeeded()
    }

    func keyboardTransitionAnimation(_ state: KeyboardState) { }

    func keyboardDidTransition(_ state: KeyboardState) {
        // keyboard animation finished
    }
}
