//
//  UITableView+reusable.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import UIKit

extension UITableView {
  final func register<T: UITableViewCell>(cellType: T.Type)
    where T: ReusableView {
      self.register(cellType.nib, forCellReuseIdentifier: cellType.identifier)
  }

  final func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T
    where T: ReusableView {
      guard let cell = self.dequeueReusableCell(withIdentifier: cellType.identifier, for: indexPath) as? T else {
        fatalError(
          "Failed to dequeue a cell with identifier \(cellType.identifier) matching type \(cellType.self). "
            + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
            + "and that you registered the cell beforehand"
        )
      }
      return cell
  }

  final func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type)
    where T: ReusableView {
      self.register(headerFooterViewType.nib, forHeaderFooterViewReuseIdentifier: headerFooterViewType.identifier)
  }

  final func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewType: T.Type = T.self) -> T?
    where T: ReusableView {
      guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: viewType.identifier) as? T? else {
        fatalError(
          "Failed to dequeue a header/footer with identifier \(viewType.identifier) "
            + "matching type \(viewType.self). "
            + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
            + "and that you registered the header/footer beforehand"
        )
      }
      return view
  }
}
