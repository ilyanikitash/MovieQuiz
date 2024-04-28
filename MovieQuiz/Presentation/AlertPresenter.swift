import UIKit

class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
    
    func presenterAlert(model: AlertModel) {
        delegate?.showAlert(model: model)
    }
    
}
    


