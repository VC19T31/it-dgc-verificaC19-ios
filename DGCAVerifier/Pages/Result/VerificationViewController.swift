/*
 *  license-start
 *  
 *  Copyright (C) 2021 Ministero della Salute and all other contributors
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
*/

//
//  ResultViewController.swift
//  dgp-whitelabel-ios
//
//

import UIKit
import RealmSwift

protocol VerificationCoordinator: Coordinator {
    func dismissVerification(completion: (()->())?)
}

class VerificationViewController: UIViewController {
        
    private weak var coordinator: VerificationCoordinator?
    private var delegate: CameraDelegate?
    private var viewModel: VerificationViewModel
    
    @IBOutlet weak var resultImageHeight: NSLayoutConstraint!
    @IBOutlet weak var resultImageView: UIImageView!

    @IBOutlet weak var lastFetchLabel: AppLabel!
    @IBOutlet weak var titleLabel: AppLabel!
    @IBOutlet weak var descriptionLabel: AppLabel!
    @IBOutlet weak var closeView: UIStackView!

    @IBOutlet weak var faqStackView: UIStackView!
    @IBOutlet weak var personalDataStackView: UIStackView!
    
    @IBOutlet weak var modeLabel: AppLabel!
    
    var timer: Timer?
    
    init(coordinator: VerificationCoordinator, delegate: CameraDelegate, viewModel: VerificationViewModel) {
        self.coordinator = coordinator
        self.delegate = delegate
        self.viewModel = viewModel
        
        super.init(nibName: "VerificationViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViews()
        validate(viewModel.status)
    }
    
    private func validate(_ status: Status) {
        view.backgroundColor = status.backgroundColor
        resultImageView.image = status.mainImage
        titleLabel.text = status.title.localizeWith(getTitleArguments(status))
        descriptionLabel.text = status.description?.localized
        descriptionLabel.sizeToFit()
        lastFetchLabel.isHidden = !status.showLastFetch
        setFaq(for: status)
        setPersonalData(for: status)
        setTimerIfNeeded(for: status)
    }
    
    private func setFaq(for status: Status) {
        faqStackView.removeAllArrangedSubViews()
        let faqs = status.faqs
        guard !faqs.isEmpty else { return }
        faqs.forEach { faqStackView.addArrangedSubview(getFaq(from: $0)) }
    }
    
    private func setPersonalData(for status: Status) {
        personalDataStackView.superview?.isHidden = true
        personalDataStackView.removeAllArrangedSubViews()
        guard status.showPersonalData else { return }
        guard let cert = viewModel.hCert else { return }
        guard !cert.name.isEmpty else { return }
        guard !cert.birthDate.isEmpty else { return }
        let name = getResult(cert.name, for: "result.name")
        let birthDate = getResult(cert.birthDate, for: "result.birthdate")
        personalDataStackView.addArrangedSubview(name)
        personalDataStackView.addArrangedSubview(birthDate)
        personalDataStackView.superview?.isHidden = false
    }

    private func initializeViews() {
        setLastFetch()
        setCard()
        setCloseView()
        setScanMode()
        resultImageHeight.constant *= Font.scaleFactor
    }
    
    private func getResult(_ description: String, for title: String) -> ResultView {
        let view = ResultView()
        view.fillView(with: .init(title: title, description: description))
        return view
    }
    
    private func getFaq(from faq: Link) -> FaqView {
        let view = FaqView()
        let tap = UrlTapGesture(target: self, action: #selector(faqDidTap))
        tap.url = faq.url
        view.fillView(with: .init(text: faq.title, onTap: tap))
        return view
    }
    
    private func getTitleArguments(_ status: Status) -> [CVarArg] {
        guard status.showCountryName else { return [] }
        return [viewModel.getCountryName()]
    }
    
    @objc func faqDidTap(recognizer: UrlTapGesture) {
        guard let url = URL(string: recognizer.url ?? "") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func dismissVC() {
        hapticFeedback()
        timer?.invalidate()
        coordinator?.dismissVerification(completion: nil)
        delegate?.startOperations()
    }
    
    private func setScanMode() {
        modeLabel.textColor = Palette.white
        
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        var mode: String = ""
        
        switch scanMode{
        case Constants.scanMode2G:
            mode = "result.scan.mode.2G".localized
        case Constants.scanMode3G:
            mode = "result.scan.mode.3G".localized
        case Constants.scanModeBooster:
            mode = "result.scan.mode.Boster".localized
        case Constants.scanModeSchool:
            mode = "result.scan.mode.Scuola".localized
        case Constants.scanMode50:
            mode = "result.scan.mode.50".localized
        default:
            break
        }
        
        modeLabel.text = mode
    }
    
    private func setLastFetch() {
        lastFetchLabel.textColor = Palette.white
        let text = "result.last.fetch".localized + " "
        let date = Date().toDateTimeReadableString
        lastFetchLabel.text = text + date
    }
    
    private func setCard() {
        let cardView = view.subviews.first
        cardView?.cornerRadius = 4
        cardView?.addShadow()

    }
    
    private func setCloseView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        closeView.addGestureRecognizer(tap)
    }
    
    private func hapticFeedback() {
        DispatchQueue.main.async {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    private func setTimerIfNeeded(for status: Status) {
        let isTotemModeActive = Store.getBool(key: .isTotemModeActive)
        guard isTotemModeActive else { return }
        guard status.isValidState else { return }
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(dismissVC), userInfo: nil, repeats: false)
    }
}

class UrlTapGesture: UITapGestureRecognizer {
    var url: String?
}
