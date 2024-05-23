import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
       
    // MARK: - IBOutlet
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func lockButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    func unlockButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        let generator = UINotificationFeedbackGenerator()
        if isCorrectAnswer {
            generator.notificationOccurred(.success)
        } else {
            generator.notificationOccurred(.error)
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func clearImageBorder() {
        imageView.layer.borderWidth = 0
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let errorAlertModel = AlertModel(title: "Error",
                                    message: message,
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] in
                                        guard let self = self else { return }
                                        self.presenter.restartGame()
                                    })
        let alertPresenter = AlertPresenter()
        alertPresenter.showAlert(vc: MovieQuizViewController(), model: errorAlertModel)
    }
    
    
    
    // MARK: - IBAction
    
    @IBAction private func noButtonClicker(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicker(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
}
