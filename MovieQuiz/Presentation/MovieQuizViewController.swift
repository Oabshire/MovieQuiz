import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Mock data
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    @IBOutlet private weak var qestionTitleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    private var currentQuestionIndex = 0
    private var correctAnswers = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        qestionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)

        let currentStep = convert(model: questions[currentQuestionIndex])
        show(quiz: currentStep)

    }
    // MARK: - Private funcs 
    @IBAction private func noButtonClicked(_ sender: Any) {
        if !questions[currentQuestionIndex].correctAnswer {
            correctAnswers += 1
        }
        showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer == false)
    }
    @IBAction private func yesButtonClicked(_ sender: Any) {
        if questions[currentQuestionIndex].correctAnswer {
            correctAnswers += 1
        }
        showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer == true)
    }

    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 6

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0

        if currentQuestionIndex == questions.count - 1 {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/10",
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {

            currentQuestionIndex += 1

            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)


            show(quiz: viewModel)
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
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0

            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.image) ?? UIImage()
        let question = model.text
        let questionNumber =  "\(currentQuestionIndex + 1)/\(questions.count)"
        return QuizStepViewModel(image: image, question: question, questionNumber: questionNumber)
    }

}

struct QuizQuestion: Equatable {
    let image: String
    let text: String
    let correctAnswer: Bool
}

struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}
