import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10

    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        questionFactory = QuestionFactory()
        questionFactory?.delegate = self

        alertPresenter = AlertPresenter()
        statisticService = StatisticService()

        questionFactory?.requestNextQuestion()
    }
    // MARK: - Private functions
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        if !currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        if currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }

    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 6

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // слабая ссылка на self
            guard let self = self else { return } // разворачиваем слабую ссылку
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0

        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: alertMessage,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        indexLabel.text = step.questionNumber
        questionLabel.text = step.question

        yesButton.isEnabled = true
        noButton.isEnabled = true
    }


    private func show(quiz result: QuizResultsViewModel) {
        let alertModel =  AlertModel(title:  result.title,
                                     message:  result.text,
                                     buttonText:  result.buttonText) { [ weak self ] in
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.showAlert(in: self, alertModel)
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    private func setupUI() {
        questionTitleLabel.font = Fonts.ysDisplayMedium20
        indexLabel.font = Fonts.ysDisplayMedium20
        questionLabel.font = Fonts.ysDisplayBold23
        yesButton.titleLabel?.font = Fonts.ysDisplayMedium20
        noButton.titleLabel?.font = Fonts.ysDisplayMedium20
    }

    private var alertMessage: String  {
        guard let statisticService = statisticService else { return "Ваш результат: \(correctAnswers)/10" }
        return """
Ваш результат: \(correctAnswers)/10
Количество сыгранных квизов: \(statisticService.gamesCount)
Рекорд: \(statisticService.bestGame.correct)/10 (\(statisticService.bestGame.date.dateTimeString))
Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
"""
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
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
}

