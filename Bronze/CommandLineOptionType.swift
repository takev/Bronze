// Bronze - A standard library for Swift.
// Copyright (C) 2015-2016  Take Vos
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


public enum CommandLineOptionType: Equatable {
case OPTION(String)
case OPTION_ARGUMENT(String, String)
case SHORT_OPTION(String)
case SHORT_OPTION_ARGUMENT(String, String)
case NON_OPTION(String)
}

public func ==(lhs: CommandLineOptionType, rhs: CommandLineOptionType) -> Bool {
    switch (lhs, rhs) {
    case (.OPTION(let lx),                          .OPTION(let rx))                            where lx == rx:             return true
    case (.OPTION_ARGUMENT(let lx, let ly),         .OPTION_ARGUMENT(let rx, let ry))           where lx == rx && ly == ry: return true
    case (.SHORT_OPTION(let lx),                    .SHORT_OPTION(let rx))                      where lx == rx:             return true
    case (.SHORT_OPTION_ARGUMENT(let lx, let ly),   .SHORT_OPTION_ARGUMENT(let rx, let ry))     where lx == rx && ly == ry: return true
    case (.NON_OPTION(let lx),                      .NON_OPTION(let rx))                        where lx == rx:             return true
    default: return false
    }
}
