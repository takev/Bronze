// Bronze - A standard library for Swift.
// Copyright (C) 2015  Take Vos
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

enum OptionValueType {
case BOOLEAN(Bool)
case STRING(String)
case INTEGER(Int)
case REAL(Double)
}

func isSameType(lhs: OptionValueType, _ rhs: OptionValueType) -> Bool {
    switch (lhs, rhs) {
    case (.BOOLEAN(_),  .BOOLEAN(_)):   return true
    case (.STRING(_),   .STRING(_)):    return true
    case (.INTEGER(_),  .INTEGER(_)):   return true
    case (.REAL(_),     .REAL(_)):      return true
    default:                            return false
    }
}

