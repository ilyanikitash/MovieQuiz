import UIKit

final class AlertPresenter: AlertPresenterDelegate {
    weak var delegate: UIViewController?
    
    init(delegate: UIViewController? = nil) {
        self.delegate = delegate
    }
    func showAlert(model: AlertModel) {
        let alertController = UIAlertController(title: model.title,
                                                message: model.message,
                                                preferredStyle: .alert)
        alertController.view.accessibilityIdentifier = "Result Alert"
        let action = UIAlertAction(title: model.buttonText,
                                   style: .default) { _ in
                    model.completion()
                }
        alertController.addAction(action)
        delegate?.present(alertController, animated: true, completion: nil)
    }
}
    


