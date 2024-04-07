import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    // Оутлеты
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    // добавил оутлеты кнопок для реализации логики, описанной ниже
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // Переменные
    private var currentQuestionIndex = 0 // текущей индекс вопроса в массиве моковых данных
    private var correctAnswers = 0 // счетчик правильных ответов
    
    override func viewDidLoad() {
        super.viewDidLoad()
        show(quiz: convert(model: questions.first ?? QuizQuestion(image: "", text: "", correctAnswer: true)))
    }
    // Экшены
    @IBAction private func noButtonClicker(_ sender: Any) {
        
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
    @IBAction private func yesButtonClicker(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    // структура моковых данных
    private struct QuizQuestion {
        let image: String // совпадает ли название фильма с названием картинки афиши
        let text: String // вопрос о рейтинге фильма
        let correctAnswer: Bool // правильный ответ на вопрос
    }
    
    // MARK: - view models
    // вью модель экрана
    private struct QuizStepViewModel {
      let image: UIImage // картинка с афишей
      let question: String // вопрос о рейтинге
      let questionNumber: String // порядковый номер вопроса
    }
    
    // вью модель результатов
    private struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    // массив с моковыми данными
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", 
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "The Dark Knight",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "Kill Bill",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "The Avengers",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "Deadpool",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "The Green Knight",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "Old",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false),
        QuizQuestion(image: "Tesla",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false),
        QuizQuestion(image: "Vivarium",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false)
    ]
    
    // MARK: - functions
    
    // конвертируем моковые данные во вью модель
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let converted: QuizStepViewModel
        if let value = UIImage(named: model.image) {
            converted = QuizStepViewModel(image: value, question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        } else {
            converted = QuizStepViewModel(image: UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
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
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResult()
            self.unlockButtons() // разрешаем нажатия на кнопки когда появляется следующий вопрос
        }

    }
    
    // показываем вопрос
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    // здесь добавляем функции которые разрешают или запрещают нажатия на кнопки
    // это сделано для того, чтобы пользователь не мог пропускать вопросы, потому что следующий вопрос появляется через секунду после предыдущего, а кнопки активны всегда
    // из-за этого бывает сбиваются результаты и выглядит все не очень красиво :)
    private func lockButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    private func unlockButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questions.count - 1 {
            show(quiz: QuizResultsViewModel(title: "Раунд окончен", text: "Ваш результат: \(correctAnswers)/10", buttonText: "Сыграть еще раз"))
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [self] _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            imageView.layer.borderWidth = 0 // при перезапуске пропадает рамка (вроде нигде в ТЗ об этом не было сказано, но как будто логично было это сделать пусть и таким кривым способом)
            show(quiz: self.convert(model: questions.first ?? QuizQuestion(image: "", text: "", correctAnswer: true)))
            
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}


/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
