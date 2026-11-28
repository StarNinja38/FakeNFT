import UIKit

struct SortOption {
    let title: String
    let action: () -> Void
}

extension UIViewController {
    func showSortSheet(options: [SortOption], onClose: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: NSLocalizedString("Sort.title", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        options.forEach { option in
            alert.addAction(UIAlertAction(title: option.title, style: .default) { _ in
                option.action()
                onClose?()
            })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Sort.close", comment: ""), style: .cancel) { _ in
            onClose?()
        })
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
