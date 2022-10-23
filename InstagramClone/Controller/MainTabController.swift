//
//  MainTabController.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/21.
//

import UIKit
import FirebaseAuth

final class MainTabController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewControllers()
        checkIfUserIsLoggedIn()
//        logout()
    }
    
    // MARK: - API
    
    /// 유저 로그인 상태 체크 : 탭컨트롤러가 생성 된 뒤 가장 먼저 호출 돼서, user의 auth 정보가 존재하지 않으면 화면을 덮어버리는 개념.
    func checkIfUserIsLoggedIn() {
        // user의 auth 정보가 존재하지 않으면,
        if Auth.auth().currentUser == nil {
            // ⭐️⭐️⭐️ 위의 Firebase Auth checking은 비동기 이므로, UI Update는 main thread에서 실행
            DispatchQueue.main.async {
                let vc = LoginController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen // 전체화면으로 덮음.
                self.present(nav, animated: true, completion: nil)
            }
            
        }
    }
    
    /// 로그아웃
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("##### Firebase Auth 로그아웃 실패: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Helpers
    
    func configureViewControllers() {
        view.backgroundColor = .white
        tabBar.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        
        let layout = UICollectionViewFlowLayout()   // 🎾 FlowLayout으로 해야 함. 많이들 하는 실수.
        // UINavigationController 형식.
        let feed = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"),
                                                rootViewController: FeedController(collectionViewLayout: layout))
        
        let search = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"),
                                                  rootViewController: SearchController())
        
        let imageSelector = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"),
                                                         rootViewController: ImageSelectorController())
        
        let notifications = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"),
                                                         rootViewController: NotificationController())
        
        let profile = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"),
                                                   rootViewController: ProfileController())
        
        tabBar.tintColor = .black
        
        // UINavigationController 배열을 viewControllers 에 할당함. (super VC가 UITabBarController 이므로 하단에 탭바로 생김.)
        viewControllers = [feed, search, imageSelector, notifications, profile]
    }
    
    func templateNavigationController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = .black
        return nav
    }
    
}
