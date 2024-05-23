import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // MARK: - Private Properties
    private var statisticService: StatisticServiceProtocol!
    private var currentQuestionIndex: Int = 0
    private weak var viewController: MovieQuizViewController?
    
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var correctAnswers = 0
    // MARK: - inits
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController as? MovieQuizViewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Public methods
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
        
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func didAnswer(isCorrect: Bool) {
        if isCorrect{
            correctAnswers += 1
        }
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        viewController?.lockButtons()
        didAnswer(isCorrect: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
            self.viewController?.clearImageBorder()
        }

    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                          question: model.text,
                          questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    // MARK: - Private methods
    private func showNextQuestionOrResult() {
        if self.isLastQuestion() {
            
            statisticService?.store(correct: correctAnswers, total: self.questionsAmount)
            
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
                                self.restartGame()
                                self.viewController?.unlockButtons()
                                
                            })
            let alertPresenter = AlertPresenter()
            alertPresenter.showAlert(vc: viewController! as UIViewController, model: alertModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            viewController?.unlockButtons()
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        showAnswerResult(isCorrect:
                        givenAnswer == currentQuestion.correctAnswer)
    }
    
    
}
