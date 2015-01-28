//
//  Array2D.swift
//  peril
//
//  Created by Nico Hämäläinen on 12/01/15.
//  Copyright (c) 2015 sizeof.io. All rights reserved.
//

import Foundation
import Dollar

public struct Array2D<T>: Printable {

  let columns: Int
  let rows: Int

  var array: Array<T?>

  init(columns: Int, rows: Int) {
    self.columns = columns
    self.rows = rows
    array = Array<T?>(count: rows*columns, repeatedValue: nil)
  }

  subscript(column: Int, row: Int) -> T? {
    get {
      return array[row*columns + column]
    }

    set {
      array[row*columns + column] = newValue
    }
  }

  func shuffle() {
    $.shuffle(array)
  }

  public var description: String {
    var res = ""
    for row in 0..<rows {
      for col in 0..<columns {
        res += "\(self[col, row]!), "
      }
      res += "\n"
    }
    return res
  }

}