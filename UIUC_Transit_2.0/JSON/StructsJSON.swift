//
//  StructsJSON.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 7/14/18.
//
//  Copyright (c) 2018, Pradeep Senthil
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  * Neither the name of the copyright holder nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


/// This struct is for the JSON recieved through the current list of stops based on the user's loction.
struct mtd_stop_loc: Codable{
    let stops: [STOP_INFO]
    
    struct STOP_INFO: Codable{
        let stop_id: String
        let stop_name: String
        let code: String
        let distance: Double
        let stop_points: [STOP_POINTS]
        struct STOP_POINTS: Codable{
            let code: String
            let stop_id: String
            let stop_lat: Double
            let stop_lon: Double
            let stop_name: String
        }
    }
}


/// This struct is for the JSON recieved through the current list of routes based on the given stop id chosen by the user.
struct mtd_routes: Codable{
    let departures: [DEPATURE_INFO]
    
    struct DEPATURE_INFO: Codable{
        let stop_id: String
        let headsign: String
        let route: ROUTES
        struct ROUTES: Codable{
            let route_color: String
            let route_id: String
            let route_long_name: String
            let route_text_color: String
        }
        let scheduled: String
        let expected: String
        let expected_mins: Int
    }
}
