//
//  CommonMethod.swift
//  PracticleTask
//
//  Created by krina kalariya on 26/04/24.
//

import Foundation
import UIKit

class CommonMethod : NSObject {
    
    let boundary = "Boundary-\(UUID().uuidString)"
    static let shared = CommonMethod()
    var semaphore = DispatchSemaphore (value: 0)
    
    func postApiCall(isGet:Bool = false,vc:UIViewController,endPoint:String,_ block : @escaping (Data?,String?,Int?) -> Void) {
//        DispatchQueue.main.async {
        vc.view.endEditing(true)
//        }
        if !Reachability.isConnectedToNetwork(){
            vc.showToast(toastMessage: "Please Check Internet connection",duration: 2.0,bottomSpace: 110)
            block(nil,"Please Connect To Internet",nil)
            return
        }
        DispatchQueue.main.async {
                CommonMethod.startProgress(viewController: vc)
        }
       
        let baseUrl = BaseURL.appURL + endPoint
        #if DEBUG
            print("baseurl post api call",baseUrl)
        #endif
        var request = URLRequest(url: URL(string: baseUrl)!,timeoutInterval: Double.infinity)

        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = isGet ? "GET" : "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                    switch statusCode {
                    case 206,402,403:
                        print("Wrong status code",statusCode)
                        return
                    default:
                        print()
                    }
            }
            
            guard let data = data else {
                #if DEBUG
                    print("Error  in api call of \(baseUrl) = : =  ",String(describing: error))
                #endif
                self.semaphore.signal()
                    DispatchQueue.main.async {
                            CommonMethod.stopProgress(viewController: vc)
                    }
                if let httpResponse = response as? HTTPURLResponse {
                    #if DEBUG
                        print("error \(httpResponse.statusCode)")
                    #endif
                    let statusCode = httpResponse.statusCode
                    block(nil,error?.localizedDescription,statusCode)
                } else {
                    block(nil,error?.localizedDescription,nil)
                }
                return
            }
            #if DEBUG
//                printDebug("responsee of \(baseUrl) = : = ",String(data: data, encoding: .utf8)!)
            #endif
            self.semaphore.signal()
                DispatchQueue.main.async {
                    CommonMethod.stopProgress(viewController: vc)
                }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String : Any]
                if let status = json?["status"] as? Int {
                    print("status",status)
                    switch status {
                    case 403,206,402:
                        let msg = json?["message"] as? String ?? ""
                        return
                    default :
                        break
                    }
                }
                if let status = json?["status"] as? String {
                    print("status",status)
                    switch status {
                    case "403","206","402":
                        let msg = json?["message"] as? String ?? ""
                        return
                    default :
                        break
                    }
                }
            } catch {
                print(error)
            }
            print("Post Api url response",String(decoding: data, as: UTF8.self))
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                block(data,nil,statusCode)
            } else {
                block(data,nil,nil)
            }
        }
        task.resume()
        self.semaphore.wait()
    }
    
    //MARK: Add loader
    static func startProgress(viewController: UIViewController){
        var spinnerView : SpinnerView?
        
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
            let view1 = UIView(frame: window.bounds)
            view1.isUserInteractionEnabled = false
            let width = view1.frame.size.width / 2
            let height = view1.frame.size.height / 4 - 45
            let transparentBackground = UIView(frame: UIScreen.main.bounds)
            transparentBackground.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
            transparentBackground.tag = 1000000
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.addSubview(transparentBackground)
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.bringSubviewToFront(transparentBackground)
            let viewBG = UIView(frame: CGRect(x: view1.frame.size.width / 2 - width / 2 + 15, y: view1.frame.size.height / 2 - height / 2, width: width - 15 , height: 60))
            viewBG.backgroundColor = UIColor.lightGray
            viewBG.layer.cornerRadius = viewBG.frame.size.height / 2
            
            spinnerView = SpinnerView(frame: CGRect(x: 15, y: viewBG.frame.size.height / 2 - 15 , width: 30, height: 30))
            viewBG.addSubview(spinnerView!)
            
            let lblText = UILabel(frame:  CGRect(x: (spinnerView?.frame.origin.x)! + (spinnerView?.frame.size.width)! + 10 ,y: ((spinnerView?.frame.size.height)! / 2) , width:viewBG.frame.size.width - (spinnerView?.frame.size.width)! - 35, height: 35))
            //            lblText.backgroundColor = .red
            lblText.textColor = .black
            lblText.text = "Please Wait..."
            lblText.font = UIFont(name: "SF-Pro-Text-Medium", size: 16)
            viewBG.addSubview(lblText)
            transparentBackground.addSubview(viewBG)
    }
    
    //MARK: Remove Loader
    static func stopProgress(viewController: UIViewController){
        DispatchQueue.main.async {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
            let view1 = UIView(frame: window.bounds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                view1.isUserInteractionEnabled = true
                if let viewWithTag =  UIApplication.shared.windows.filter({$0.isKeyWindow}).first!.viewWithTag(1000000) {
                    viewWithTag.removeFromSuperview()
                }else{
                    print("No!")
                }
            })
        }
    }
    
}
enum BaseURL {
    static let appURL = "https://jsonplaceholder.typicode.com/"
}
enum Endpoints {
    static let post = "posts"
}

enum Storyboard {
    enum Name {
        case Main(String)
        
        var controller: UIViewController? {
            switch self {
            case .Main(let id):
                return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: id)
            }
        }
    }
    
    enum Id: String {
        case HomeVc
        case DetailVc
    }
}
