//
//  DetailVc.swift
//  PracticleTask
//
//  Created by krina kalariya on 27/04/24.
//

import UIKit

class DetailVc: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var userIdLbl: UILabel!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bodyLbl: UILabel!
    
    var userData : UserDetailModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setData()
    }
    
    func setData() {
        self.navigationController?.title = title
        self.userIdLbl.text = "\(userData?.userID ?? 0)"
        self.idLbl.text = "\(userData?.id ?? 0)"
        self.titleLbl.text = "\(userData?.title ?? "")"
        self.bodyLbl.text = "\(userData?.body ?? "")"
        self.bgView.addDropShadow()
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
