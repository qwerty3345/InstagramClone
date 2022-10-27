//
//  MainTabController.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/21.
//

/**
 
 앱 동작 흐름 :
 
 LoginController 내부에 delegate: AuthDelegate 가 있고,
 로그인이 완료되면 delegate.authComplete() 를 실행함.

 MainTabController 에서 해당 AuthDelegate를 구현하고 있고, 대신 그 동작을 수행함. (loginVC.delegate = self)
 구현한 authComplete() 에서 fetchUser() 를 실행하며 user 객체를 받아오고 dismiss 를 통해 VC 를 종료함. (이전 LoginController 를 종료)

 fetchUser 에서 받아온 User 객체를 멤버변수에 할당하고, 멤버변수 user의 didSet에서 configureViewControllers(withUser: user)를 실행.

 해당 configureVC에서 ProfileController 를 생성할 때, 애초에 user 객체를 생성자로 받아서 생성함.

 그리고 user 객체를 의존성 주입으로 (생성자로) 받아온 ProfileController에서
 헤더에 ProfileHeaderViewModel(user: user)을 생성하고 넣어줌.
 */


import UIKit
import FirebaseAuth

final class MainTabController: UITabBarController {
    
    // MARK: - Lifecycle
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            // 하단 TabBar를 구성하는 ViewControllers들을 지정함. (user 객체를 넘기면서)
            configureViewControllers(withUser: user)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 유저 로그인 상태 체크
        checkIfUserIsLoggedIn()
        // 유저 정보 받아오기
        fetchUser()
    }
    
    // MARK: - API
    
    func fetchUser() {
        // 유저 정보를 받아오고,
        UserService.fetchUser { user in
            
            // user 멤버변수에 할당 ( user의 didSet 호출)
            self.user = user
            
            // 네비게이션 타이틀을 유저네임으로 표시 함.
            self.navigationItem.title = user .username
        }
    }
    
    /// 유저 로그인 상태 체크 : 탭컨트롤러가 생성 된 뒤 가장 먼저 호출 돼서, user의 auth 정보가 존재하지 않으면 화면을 덮어버리는 개념.
    func checkIfUserIsLoggedIn() {
        // user의 auth 정보가 존재하지 않으면,
        if Auth.auth().currentUser == nil {
            // ⭐️⭐️⭐️ 위의 Firebase Auth checking은 비동기 이므로, UI Update는 main thread에서 실행
            DispatchQueue.main.async {
                let vc = LoginController()
                vc.delegate = self
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
    
    func configureViewControllers(withUser user: User) {
        view.backgroundColor = .white
        tabBar.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        
        let layout = UICollectionViewFlowLayout()   // 🎾 FlowLayout으로 해야 함. 많이들 하는 실수.
        // UINavigationController 형식.
        let feed = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"),
                                                rootViewController: FeedController(collectionViewLayout: layout))   // 컬렉션뷰컨트롤러 이기에 layout 지정.
        
        let search = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"),
                                                  rootViewController: SearchController())
        
        let imageSelector = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"),
                                                         rootViewController: ImageSelectorController())
        
        let notifications = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"),
                                                         rootViewController: NotificationController())
        
//        let profileLayout = UICollectionViewFlowLayout()
        // DI(의존성주입)으로 User 객체를 애초에 받아서 ProfileController 를 생성함.
        let profileController = ProfileController(user: user)
        let profile = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"),
                                                   rootViewController: profileController)
        
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

extension MainTabController: AuthenticationDelegate {
    // 유저 인증 (로그인 or 회원가입)이 완료되면,
    func authenticationDidComplete() {
        print("#### 유저 인증 완료.")
        // 유저 정보를 받아오고
        fetchUser()
        // 로그인 / 회원가입 화면을 종료함.
        self.dismiss(animated: true)
    }
    
    
}
