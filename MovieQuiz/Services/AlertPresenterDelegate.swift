import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func showAlert(model: AlertModel) 
}
