//  Edited SliderRow.swift from Eureka
//
//  CheckRow.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Eureka

// MARK: CheckCell

public final class CustomCheckCell : Cell<Bool>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func update() {
        super.update()
        accessoryType = row.value == true ? .checkmark : .none
        editingAccessoryType = accessoryType
        selectionStyle = .default
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        if row.isDisabled {
            tintColor = UIColor(red: red, green: green, blue: blue, alpha: 0.3)
            selectionStyle = .none
        }
        else {
            tintColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
    }
    
    open override func setup() {
        super.setup()
        self.tintColor = COLOR_HIGHLIGHTED
        accessoryType =  .checkmark
        editingAccessoryType = accessoryType
    }
    
    open override func didSelect() {
        row.value = row.value ?? false ? false : true
        row.deselect()
        row.updateCell()
    }
    
}

// MARK: CheckRow

open class _CustomCheckRow: Row<CustomCheckCell> {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

///// Boolean row that has a checkmark as accessoryType
public final class CustomCheckRow: _CustomCheckRow, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
