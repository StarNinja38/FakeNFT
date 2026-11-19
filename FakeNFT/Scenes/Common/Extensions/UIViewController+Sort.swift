import UIKit

struct SortOption {
    let title: String
    let action: () -> Void
}

extension UIViewController {
    func showSortSheet(options: [SortOption]) {
        let alert = UIAlertController(
            title: NSLocalizedString("Sort.title", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        options.forEach { option in
            alert.addAction(UIAlertAction(title: option.title, style: .default) { _ in
                option.action()
            })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Sort.close", comment: ""), style: .cancel))
        present(alert, animated: true)
    }

    func makeSortButton(action: Selector) -> UIBarButtonItem {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "text.justify.leading"),
            style: .plain,
            target: self,
            action: action
        )
        button.tintColor = .ypBlack
        return button
    }
}
