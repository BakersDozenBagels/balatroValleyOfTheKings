--[[

Copyright (C) 2025  BakersDozenBagels

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

--]]

return {
    descriptions = {
        Joker = {
            j_valleyOfTheKings_Bes = {
                name = 'Bes',
                text = {'{C:red}Prevents{} cards above', '{C:attention}#1#{} from scoring.',
                        'Scored cards give {X:mult,C:white}X#2#{} Mult'}
            },
            j_valleyOfTheKings_Isis = {
                name = 'Isis',
                text = {'Adds {C:attention}#1#{} copies of the',
                        '{C:attention}most recently {C:red}destroyed{} {C:attention}playing card',
                        'to your deck when {C:attention}Blind{} is selected',
                        '{C:inactive}(Does nothing if no card has been destroyed)'}
            },
            j_valleyOfTheKings_Hapy = {
                name = 'Hapy',
                text = {'Adds a copy of the most', 'recently scored {C:attention}#1#{} to your deck',
                        'when {C:attention}Blind{} is selected'}
            },
            j_valleyOfTheKings_Khnum = {
                name = 'Khnum',
                text = {'Earn {C:money}$#1#{} every', '{C:attention}#2#{} hands played', '{C:inactive}#3#'}
            },
            j_valleyOfTheKings_Min = {
                name = 'Min',
                text = {'{C:green}#1# in #2#{} chance to create',
                        'a {C:dark_edition}negative{} copy of a random {C:attention}Joker',
                        'after defeating a {C:attention}Boss Blind{}'}
            },
            j_valleyOfTheKings_Thoth = {
                name = 'Thoth',
                text = {'{C:tarot}Tarot{} cards in your', '{C:attention}consumable{} area give',
                        '{X:mult,C:white}X#1#{} Mult'}
            },
            j_valleyOfTheKings_Nut = {
                name = 'Nut',
                text = {'Create a {C:dark_edition}Negative {C:tarot}High Priestess',
                        'when {C:attention}Blind{} is selected'}
            },
            j_valleyOfTheKings_Sobek = {
                name = 'Sobek',
                text = {'Create a {C:dark_edition}Negative {C:tarot}Lovers', 'when {C:attention}Blind{} is selected'}
            },
            j_valleyOfTheKings_Ptah = {
                name = 'Ptah',
                text = {'Create {C:attention}two {C:dark_edition}Negative {C:tarot}Worlds',
                        'when {C:attention}Blind{} is selected'}
            },
            j_valleyOfTheKings_Horus = {
                name = 'Horus',
                text = {'Scored {C:attention}Kings', 'give {X:mult,C:white}X#1#{} Mult'}
            },
            j_valleyOfTheKings_Erebus = {
                name = 'Erebus',
                text = {'Gains {X:mult,C:white}X#1#{} Mult when', 'a {C:clubs}Club{} or {C:spades}Spade', 'is scored',
                        '{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)'}
            }
        }
    },
    misc = {}
}
