import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - Private Properties
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    
    private var questionFactory: QuestionFactoryProtocol?
    
    private var alertPresenter: AlertPresenter?
    
    private let presenter = MovieQuizPresenter()
    
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        
        showLoadingIndicator()
        questionFactory.loadData()
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    //MARK: -QuestionFactoryDeledate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
               return
           }

           currentQuestion = question
           let viewModel = presenter.convert(model: question)
        
           DispatchQueue.main.async { [weak self] in
               self?.show(quiz: viewModel)
           }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Private methods
    
    // окрашиваем рамку 
    private func showAnswerResult(isCorrect: Bool) {
        lockButtons() // лочим нажатия на кнопки, когда ответ был получен
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
            let generator = UINotificationFeedbackGenerator() // добавил taptic отклик
                generator.notificationOccurred(.success)
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            let generator = UINotificationFeedbackGenerator() // добавил taptic отклик
                generator.notificationOccurred(.error)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
            self.imageView.layer.borderWidth = 0
        }

    }
    
    // показываем вопрос
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func lockButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    private func unlockButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    private func showNextQuestionOrResult() {
        if presenter.isLastQuestion() {
            
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let alertModel = AlertModel(
                            title: "Этот раунд окончен!",
                            message: """
                            Ваш результат: \(correctAnswers)/10
                            Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
                            Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(statisticService?.bestGame.total ?? 0) (\(statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString))
                            Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%
                            """,
                            buttonText: "Сыграть еще раз",
                            completion: { [weak self] in
                                guard let self = self else { return }
                                self.presenter.resetQuestionIndex()
                                self.correctAnswers = 0
                                unlockButtons()
                                questionFactory?.requestNextQuestion()
                            })
            alertPresenter?.showAlert(model: alertModel)
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            unlockButtons()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let errorAlertModel = AlertModel(title: "Error",
                                    message: message,
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] in
                                        guard let self = self else { return }
                                        self.presenter.resetQuestionIndex()
                                        self.correctAnswers = 0
                                        self.questionFactory?.requestNextQuestion()
                                    })
        alertPresenter?.showAlert(model: errorAlertModel)
    }
    
    
    // MARK: - IBAction
    
    @IBAction private func noButtonClicker(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
    @IBAction private func yesButtonClicker(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
}
