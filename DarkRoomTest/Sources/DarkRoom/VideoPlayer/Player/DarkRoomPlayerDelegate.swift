//
//  DarkRoomPlayerDelegate.swift
//  
//
//  Created by Kiarash Vosough on 7/13/22.
//
//  Copyright (c) 2022 Divar
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

public protocol DarkRoomPlayerDelegate: AnyObject {
    
    /// Trigged when player's state is about to be changed
    /// - parameters:
    ///    - player: current ``DarkRoomPlayer`` instance in use
    ///    - state: new player's state
    func player(_ player: DarkRoomPlayer, willStateChange state: DarkRoomPlayerStates)
    
    /// Trigged when player's state changed
    /// - parameters:
    ///    - player: current ``DarkRoomPlayer`` instance in use
    ///    - state: new player's state
    func player(_ player: DarkRoomPlayer, didStateChange state: DarkRoomPlayerStates)

    /// Trigged when new media is set (before loading).
    /// - parameters:
    ///    - player: current ``DarkRoomPlayer`` instance in use
    ///    - media: new current media
    func player(_ player: DarkRoomPlayer, didCurrentMediaChange media: DarkRoomPlayerMedia?)

    /// Trigged when item's time updated (seek, playing, load at...)
    /// - parameters:
    ///    - player: current ``DarkRoomPlayer`` instance in use
    ///    - currentTime: current time
    func player(_ player: DarkRoomPlayer, didCurrentTimeChange currentTime: Double)
    
    /// Trigged before item's time updated (seek, playing, load at...)
    /// - parameters:
    ///    - player: current ``DarkRoomPlayer`` instance in use
    ///    - currentTime: current time
    func player(_ player: DarkRoomPlayer, willCurrentTimeChange currentTime: Double)

    /// Trigged when new media is loaded
    /// - parameters:
    ///    - player: current ``DarkRoomPlayer`` instance in use
    ///    - itemDuration: item's duration
    func player(_ player: DarkRoomPlayer, didItemDurationChange itemDuration: Double?)

    /// Trigged when action initiated by user has no effect on the player
    /// - parameters:
    ///    - player: current ``DarkRoomPlayer`` instance in use
    ///    - error: 
    func player(_ player: DarkRoomPlayer, catched error: Error)

    /// Trigged when item play to his end time even on loop mode
    /// - parameters:
    ///    - player: current ``DarkRoomPlayer`` instance in use
    ///    - endTime: end time detected
    func player(_ player: DarkRoomPlayer, didItemPlayToEndTime endTime: Double)
}

/// Optional methods
public extension DarkRoomPlayerDelegate {

    func player(_ player: DarkRoomPlayer, didStateChange state: DarkRoomPlayerStates) {}
    
    func player(_ player: DarkRoomPlayer, didCurrentMediaChange media: DarkRoomPlayerMedia?) {}
    
    func player(_ player: DarkRoomPlayer, didCurrentTimeChange currentTime: Double) {}
    
    func player(_ player: DarkRoomPlayer, didItemDurationChange itemDuration: Double?) {}
    
    func player(_ player: DarkRoomPlayer, catched error: Error) {}
    
    func player(_ player: DarkRoomPlayer, didItemPlayToEndTime endTime: Double) {}
}
