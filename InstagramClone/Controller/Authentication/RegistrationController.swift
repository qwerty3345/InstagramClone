//
//  RegistrationController.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/23.
//

import UIKit

final class RegistrationController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: AuthenticationDelegate?
    private var viewModel = RegistrationViewModel()
    private var profileImage: UIImage?
    
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo") , for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleProfilePhotoSelect), for: .touchUpInside)
        return button
    }()
    
    private let emailTextField: UITextField = {
        let tf = CustomTextField(placeholder: "이메일")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = CustomTextField(placeholder: "비밀번호")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let fullNameTextField: UITextField = {
        let tf = CustomTextField(placeholder: "사용자 이름")
        return tf
    }()
    
    private let userNameTextField: UITextField = {
        let tf = CustomTextField(placeholder: "유저명")
        return tf
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(UIColor(white: 1, alpha: 0.67), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).withAlphaComponent(0.5)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "이미 계정이 있습니까?", secondPart: "로그인")
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        congifureUI()
        configureNotificationObservers()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - Actions
    
    /// 회원가입 버튼 액션
    @objc func handleSignUp() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let fullname = fullNameTextField.text,
              let username = userNameTextField.text,
              let profileImage = profileImage else { return }
        
        showLoader(true)
        
        let credentials = AuthCredentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
        
        AuthService.registerUser(withCredential: credentials) { error in
            if let error = error {
                print("##### registerUser error: \(error.localizedDescription)")
                self.showSimpleAlert(
                    withTitle: "회원가입 실패",
                    message: "양식을 다시 확인 해 주세요.",
                    buttonTitle: "확인")

                self.showLoader(false)
                return
            }
            
            print("##### 성공적으로 Firestore에 유저 정보 저장")
            self.delegate?.authenticationDidComplete()
            
            self.showLoader(false)
        }
    }
    
    /// 로그인 화면으로 이동 버튼 액션
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 텍스트 입력 시 액션  (한 글자당 호출)
    @objc func textDidChange(sender: UITextField) {
        switch sender {
        case emailTextField:
            viewModel.email = sender.text
        case passwordTextField:
            viewModel.password = sender.text
        case fullNameTextField:
            viewModel.fullname = sender.text
        case userNameTextField:
            viewModel.username = sender.text
        default:
            break
        }
        
        // protocol 에서 구현 한 메서드 (FormViewModel)
        updateForm()
    }
    
    @objc func handleProfilePhotoSelect() {
        showLoader(true)
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true) {
            self.showLoader(false)
        }
    }
    
    // MARK: - Helpers
    
    func congifureUI() {
        configureGradientLayer()
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.setDimensions(height: 140, width: 140)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, fullNameTextField, userNameTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                         paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        userNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    
}

extension RegistrationController: FormViewModel {
    func updateForm() {
        signUpButton.backgroundColor = viewModel.buttonBackgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        signUpButton.isEnabled = viewModel.formIsValid
    }
}

// MARK: - ImagePicker를 위한 delegate

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // didFinish -> 이미지 선택 완료 시 호출
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 선택 한 이미지 옵셔널 바인딩
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        // 선택 한 이미지를 profileImage 멤버 프로퍼티에 할당
        profileImage = selectedImage
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        
        
        self.dismiss(animated: true)
    }
}
