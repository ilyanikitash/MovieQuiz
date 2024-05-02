import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    // MARK: - IBOutlet
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    
    private var alertPresenter: AlertPresenter?
    
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        let questionFactory = QuestionFactory()
        statisticService = StatisticServiceImplementation()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    //MARK: -QuestionFactoryDeledate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
               return
           }

           currentQuestion = question
           let viewModel = convert(model: question)
        
           DispatchQueue.main.async { [weak self] in
               self?.show(quiz: viewModel)
           }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private methods
    
    // конвертируем моковые данные во вью модель
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let converted: QuizStepViewModel
        if let value = UIImage(named: model.image) {
            converted = QuizStepViewModel(image: value,
                                          question: model.text,
                                          questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        } else {
            converted = QuizStepViewModel(image: UIImage(),
                                          question: model.text,
                                          questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        }
       return converted
    }
    
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
            self.unlockButtons() // разрешаем нажатия на кнопки когда появляется следующий вопрос
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
        if currentQuestionIndex == questionsAmount - 1 {
            
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
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
                                self.currentQuestionIndex = 0
                                self.correctAnswers = 0
                                questionFactory?.requestNextQuestion()
                            })
            
            alertPresenter?.showAlert(model: alertModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
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
