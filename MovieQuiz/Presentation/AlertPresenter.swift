//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Onie on 8/29/25.
//

import Foundation
import UIKit

protocol AlertPresenterProtocol {
    func showAlert(in vc: UIViewController, _ alert: AlertModel)
}

class AlertPresenter: AlertPresenterProtocol {
    func showAlert(in vc: UIViewController, _ alertModel: AlertModel) {

            let alert = UIAlertController(
                title: alertModel.title,
                message: alertModel.message,
                preferredStyle: .alert)

        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
            alert.addAction(action)

        vc.present(alert, animated: true, completion: nil)
    }
}
