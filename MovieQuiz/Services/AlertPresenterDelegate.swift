import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func showAlert(vc: UIViewController, model: AlertModel)
}
