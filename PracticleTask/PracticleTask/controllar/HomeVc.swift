//
//  HomeVc.swift
//  PracticleTask
//
//  Created by krina kalariya on 26/04/24.
//

import UIKit

class HomeVc: UIViewController {

    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var postTableView: UITableView!{
        didSet {
            self.postTableView.delegate = self
            self.postTableView.dataSource = self
        }
    }
    
    var userDetailAr : [UserDetailModel]?
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.postListApi()
        // Do any additional setup after loading the view.
    }

}
extension HomeVc : UITableViewDelegate,UITableViewDataSource {
    
    func registerCell() {
        self.postTableView.register(UINib(nibName: InfoDetailCell.id, bundle: nil), forCellReuseIdentifier: InfoDetailCell.id)
    }
    
    func openUserDetail(_ indexPath : IndexPath) {
        if let detailVc = Storyboard.Name.Main(Storyboard.Id.DetailVc.rawValue).controller as? DetailVc {
            detailVc.title = "Details"
            detailVc.userData = self.userDetailAr?[indexPath.row]
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDetailAr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : InfoDetailCell = tableView.dequeueReusableCell(withIdentifier: InfoDetailCell.id, for: indexPath) as! InfoDetailCell
        cell.data = self.userDetailAr?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == ((self.userDetailAr?.count ?? 0) - 1) {
            page += 1
            self.postListApi()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.openUserDetail(indexPath)
    }
    
}
extension HomeVc {
    
    func setData() {
        DispatchQueue.main.async {
            self.postTableView.reloadData()
            self.noDataLbl.isHidden =  !(self.userDetailAr?.isEmpty ?? false)
        }
    }
    
    func postListApi() {
        let endP = Endpoints.post + "?page=\(page)"
        CommonMethod.shared.postApiCall(isGet: true, vc: self, endPoint: endP) { responseData, errorStr,httpStatusCode  in
            
            if let data = responseData {
                do {
                    let resData = try JSONDecoder().decode([UserDetailModel].self, from: data)
                    if (self.userDetailAr?.isEmpty ?? false) || (self.userDetailAr == nil) {
                        self.userDetailAr = resData
                    } else {
                        self.userDetailAr?.append(contentsOf: resData)
                    }
                    DispatchQueue.main.async {
                        self.setData()
                    }
                }
                catch {
                    self.showToast(toastMessage: error.localizedDescription, duration: 2.0,bottomSpace: 110)
                    }
            }
            else if errorStr != nil{
                self.showToast(toastMessage: errorStr ?? "", duration: 2.0,bottomSpace: 110)
            }
        }
    }
    
}
