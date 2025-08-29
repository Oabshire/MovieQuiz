//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Onie on 8/28/25.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
