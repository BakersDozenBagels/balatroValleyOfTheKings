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

]] --
SMODS.Atlas {
    key = 'Jokers',
    path = 'Jokers.png',
    px = 71,
    py = 95
}

local contributions = {
    idea = 'Idea: ',
    code = 'Code: ',
    art = 'Art: '
}
local contributors = {
    bagels = {
        text = 'BakersDozenBagels',
        fg = HEX('362708'),
        bg = HEX('EDD198')
    },
    maple = {
        text = 'Maple Maelstrom',
        fg = G.C.WHITE,
        bg = HEX('8b4513')
    },
    reaper = {
        text = 'Reaperkun',
        fg = G.C.WHITE,
        bg = G.C.UI.TEXT_DARK
    },
    revo = {
        text = 'Revo',
        fg = HEX('40093A'),
        bg = HEX('7E7AFF')
    }
}

local function Joker(o)
    o.atlas = 'Jokers'
    if o.extra then
        o.config = {
            extra = o.extra
        }
        o.extra = nil
    end
    o.pos = {
        x = o.pos[1],
        y = o.pos[2]
    }
    o.blueprint_compat = o.blueprint_compat ~= false
    o.loc_vars = o.loc_vars or function(self, info_queue, card)
        return {
            vars = type(card.ability.extra) == 'table' and card.ability.extra or {card.ability.extra}
        }
    end

    local credits = o.credits or {}
    o.credits = nil
    credits[#credits + 1] = {'idea', 'maple'}
    credits[#credits + 1] = {'idea', 'reaper'}

    local j = SMODS.Joker(o)

    local raw_obj_set_badges = j.set_badges
    j.set_badges = function(self, card, badges)
        for _, v in ipairs(credits) do
            badges[#badges + 1] = create_badge(contributions[v[1]] .. contributors[v[2]].text,
                contributors[v[2]].bg or G.C.RED, contributors[v[2]].fg or G.C.BLACK, 0.7)
        end
        if raw_obj_set_badges then
            raw_obj_set_badges(self, card, badges)
        end
    end
end

Joker {
    key = 'Bes',
    pos = {2, 0},
    extra = {5, 2},
    rarity = 3,
    cost = 8,
    credits = {{'code', 'bagels'}},
    calculate = function(self, card, context)
        if context.modify_scoring_hand then
            if context.other_card.base.nominal > card.ability.extra[1] then
                return {
                    remove_from_hand = true
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            return {
                x_mult = card.ability.extra[2]
            }
        end
    end
}

-- REGION: Isis and Hapy
-- This function is referenced in lovely.toml
function valleyOfTheKings_create_card_area()
    G.valleyOfTheKings_destroyed_card_holding_zone = CardArea(-100, -100, 0, 0, {
        type = 'discard'
    })
    G.valleyOfTheKings_king_holding_zone = CardArea(-100, -100, 0, 0, {
        type = 'discard'
    })
end

local raw_Card_remove = Card.remove
function Card:remove()
    if G.valleyOfTheKings_destroyed_card_holding_zone and not self.params.valleyOfTheKings_phantom and self.playing_card and
        not self.debuff and next(SMODS.find_card('j_valleyOfTheKings_Isis', true)) then
        for _, v in pairs(SMODS.find_card('j_valleyOfTheKings_Isis', true)) do
            v.ability.extra[2] = true
        end
        local old = G.valleyOfTheKings_destroyed_card_holding_zone.cards[1]
        if old then
            old:remove()
        end
        local clone = copy_card(self)
        clone.params.valleyOfTheKings_phantom = true
        G.valleyOfTheKings_destroyed_card_holding_zone:emplace(clone)
        G.valleyOfTheKings_destroyed_card_holding_zone:hard_set_cards()
    end
    raw_Card_remove(self)
end

local function copy_to_deck(card)
    G.playing_card = (G.playing_card and G.playing_card + 1) or 1
    local clone = copy_card(card, nil, nil, G.playing_card)
    clone.params.valleyOfTheKings_phantom = nil
    clone:add_to_deck()
    G.deck.config.card_limit = G.deck.config.card_limit + 1
    table.insert(G.playing_cards, clone)
    G.deck:emplace(clone)
    return clone
end

Joker {
    key = 'Isis',
    pos = {0, 1},
    extra = {2, false},
    rarity = 3,
    cost = 7,
    credits = {{'code', 'bagels'}},
    calculate = function(self, card, context)
        if context.setting_blind and card.ability.extra[1] >= 1 and card.ability.extra[2] then
            local last_destroyed = G.valleyOfTheKings_destroyed_card_holding_zone.cards[1]
            if last_destroyed then
                local created = {}

                for i = 1, card.ability.extra[1] do
                    created[#created + 1] = copy_to_deck(last_destroyed)
                end

                return {
                    message = localize('k_copied_ex'),
                    colour = G.C.CHIPS,
                    card = self,
                    playing_cards_created = created
                }
            end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if not from_debuff then -- If there are no Isises left, forget the tracked card
            for _, v in pairs(SMODS.find_card('j_valleyOfTheKings_Isis', true)) do
                if v ~= card then
                    return
                end
            end

            local old = G.valleyOfTheKings_destroyed_card_holding_zone.cards[1]
            if old then
                old:remove()
            end
        end
    end
}

Joker {
    key = 'Hapy',
    pos = {4, 3},
    extra = {'King', false},
    rarity = 3,
    cost = 8,
    credits = {{'code', 'bagels'}},
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card.base.value == card.ability.extra[1] and
            not card.debuff and not context.blueprint then
            local old = G.valleyOfTheKings_king_holding_zone.cards[1]
            if old then
                old:remove()
            end
            local clone = copy_card(context.other_card)
            clone.params.valleyOfTheKings_phantom = true
            G.valleyOfTheKings_king_holding_zone:emplace(clone)
            G.valleyOfTheKings_king_holding_zone:hard_set_cards()

            card.ability.extra[2] = true
        end

        if context.setting_blind and card.ability.extra[2] then
            local last_destroyed = G.valleyOfTheKings_king_holding_zone.cards[1]
            if last_destroyed then
                return {
                    message = localize('k_copied_ex'),
                    colour = G.C.CHIPS,
                    card = self,
                    playing_cards_created = {copy_to_deck(last_destroyed)}
                }
            end
        end
    end
}
-- END REGION: Isis and Hapy

Joker {
    key = 'Khnum',
    pos = {3, 3},
    extra = {5, 3, 2},
    rarity = 1,
    cost = 6,
    credits = {{'code', 'bagels'}},
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.extra[1], card.ability.extra[2], localize {
                type = 'variable',
                key = (card.ability.extra[3] == 0 and 'loyalty_active' or 'loyalty_inactive'),
                vars = {card.ability.extra[3]}
            }}
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            card.ability.extra[3] = (card.ability.extra[2] - 1 -
                                        (G.GAME.hands_played + 1 - card.ability.hands_played_at_create)) %
                                        (card.ability.extra[2])
            if card.ability.extra[3] == card.ability.extra[2] - 1 then
                return {
                    dollars = card.ability.extra[1]
                }
            end
            if card.ability.extra[3] == 0 and not context.blueprint then
                juice_card_until(card, function()
                    return card.ability.extra[3] == 0
                end)
            end
        end
    end
}

Joker {
    key = 'Min',
    pos = {2, 3},
    extra = 3,
    rarity = 3,
    cost = 9,
    credits = {{'code', 'bagels'}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        return {
            vars = {G.GAME.probabilities.normal, card.ability.extra}
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.cardarea == G.jokers and not G.game_over and G.GAME.blind.boss then
            if pseudorandom('j_valleyOfTheKings_Min') < G.GAME.probabilities.normal / card.ability.extra then
                G.E_MANAGER:add_event(Event {
                    func = function()
                        local joker = copy_card(pseudorandom_element(G.jokers.cards,
                            pseudoseed('j_valleyOfTheKings_Min_choice')), nil, nil, nil, true)
                        joker:set_edition({
                            negative = true
                        })
                        joker:add_to_deck()
                        G.jokers:emplace(joker)
                        return true
                    end
                })
                return {
                    message = localize('k_duplicated_ex')
                }
            else
                return {
                    message = localize('k_nope_ex')
                }
            end
        end
    end
}

Joker {
    key = 'Thoth',
    pos = {1, 3},
    extra = 1.5,
    rarity = 3,
    cost = 8,
    credits = {{'code', 'bagels'}},
    calculate = function(self, card, context)
        if context.joker_main then
            local flag = false
            for _, c in ipairs(G.consumeables.cards) do
                if c.config.center.set == 'Tarot' then
                    SMODS.calculate_effect({
                        x_mult = card.ability.extra,
                        juice_card = c,
                        card = context.blueprint_card or card
                    }, context.blueprint_card or card)
                end
            end
            if flag then
                return {}, true
            end
        end
    end
}

local consumable_makers = {{'Nut', 1, 'c_high_priestess', {0, 3}, 6}, {'Sobek', 1, 'c_lovers', {4, 2}, 7},
                           {'Ptah', 2, 'c_world', {3, 2}, 7}}

for _, v in ipairs(consumable_makers) do
    Joker {
        key = v[1],
        pos = v[4],
        rarity = 2,
        cost = v[5],
        credits = {{'code', 'bagels'}},
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue + 1] = {
                key = 'e_negative_consumable',
                set = 'Edition',
                config = {
                    extra = 1
                }
            }
            info_queue[#info_queue + 1] = G.P_CENTERS[v[3]]
        end,
        calculate = function(self, card, context)
            if context.setting_blind then
                for _ = 1, v[2] do
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {
                                message = localize('k_plus_tarot'),
                                colour = G.C.DARK_EDITION
                            })
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    local hp = SMODS.create_card({
                                        set = 'Planet',
                                        area = G.consumeables,
                                        key = v[3],
                                        key_append = 'j_valleyOfTheKings_Nut',
                                        no_edition = true,
                                        edition = 'e_negative'
                                    })
                                    hp:add_to_deck()
                                    G.consumeables:emplace(hp)
                                    return true
                                end
                            }))
                            return true
                        end
                    }))
                end
            end
        end
    }
end

Joker {
    key = 'Horus',
    pos = {2, 2},
    extra = 2,
    rarity = 3,
    cost = 10,
    credits = {{'code', 'bagels'}},
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card.base.value == 'King' then
            return {
                x_mult = card.ability.extra,
                juice_card = context.other_card,
                card = card
            }
        end
    end
}

Joker {
    key = 'Erebus',
    pos = {1, 2},
    extra = {0.02, 1},
    rarity = 3,
    cost = 10,
    perishable_compat = false,
    credits = {{'code', 'bagels'}},
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = card.ability.extra[2]
            }
        end

        if context.individual and context.cardarea == G.play and
            (context.other_card:is_suit('Clubs') or context.other_card:is_suit('Spades')) then
            card.ability.extra[2] = card.ability.extra[2] + card.ability.extra[1]
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT,
                card = card
            }
        end
    end
}

-- REGION: Jokers by Revo
Joker {
    key = 'Osiris',
    pos = {0, 0},
    rarity = 3,
    cost = 6,
    credits = {{'code', 'revo'}},
    calculate = function(self, card, context)
        if context.destroy_card and context.cardarea == 'unscored' then
            return {
                remove = true
            }
        end
    end
}

Joker {
    key = 'Hathor',
    pos = {1, 0},
    extra = {
        xmult = 1,
        xmult_gain = 1
    },
    rarity = 3,
    perishable_compat = false,
    credits = {{'code', 'revo'}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_lovers
        return {
            vars = {card.ability.extra.xmult, card.ability.extra.xmult_gain}
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.using_consumeable and context.consumeable.config.center.key == 'c_lovers' and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT
            }
        end
    end
}

Joker {
    key = 'Anhur',
    pos = {3, 0},
    extra = 2,
    rarity = 2,
    cost = 5,
    credits = {{'code', 'revo'}},
    calculate = function(self, card, context)
        if context.joker_main and G.GAME.blind.boss then
            return {
                xmult = card.ability.extra
            }
        end
    end
}

Joker {
    key = 'AmiUt',
    pos = {4, 0},
    extra = {
        chips = 0,
        chipg = 30,
        timer = 0
    },
    rarity = 2,
    cost = 4,
    perishable_compat = false,
    credits = {{'code', 'revo'}},
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.extra.chips, card.ability.extra.chipg, localize {
                type = 'variable',
                key = (card.ability.extra.timer >= 8 and 'loyalty_active' or 'loyalty_inactive'),
                vars = {8 - card.ability.extra.timer}
            }}
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
        if context.before and context.cardarea and card.ability.extra.timer < 9 and not context.blueprint and
            not context.repetition and not context.individual then
            card.ability.extra.timer = card.ability.extra.timer + 1
            if card.ability.extra.timer == 8 then
                juice_card_until(card, function()
                    return card.ability.extra.timer == 8
                end)
            end
            if card.ability.extra.timer >= 9 then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chipg
                card.ability.extra.timer = 0
                return {
                    message = localize('k_upgrade_ex')
                }
            end
        end
    end
}

Joker {
    key = 'Ra',
    pos = {1, 1},
    rarity = 3,
    cost = 9,
    credits = {{'code', 'revo'}},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition then
            if context.other_card:is_suit('Hearts') then
                return {
                    repetitions = 2
                }
            end
        end
    end
}

Joker {
    key = 'Kek',
    pos = {2, 1},
    rarity = 3,
    cost = 9,
    credits = {{'code', 'revo'}},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition then
            if context.other_card:is_suit('Clubs') then
                return {
                    repetitions = 2
                }
            end
        end
    end
}

Joker {
    key = 'Set',
    pos = {3, 1},
    rarity = 3,
    cost = 8,
    credits = {{'code', 'revo'}},
    calculate = function(self, card, context)
        if context.final_scoring_step and context.cardarea then
            local done = false
            for k, v in ipairs(context.scoring_hand) do
                if not v.edition then
                    done = true
                    G.E_MANAGER:add_event(Event {
                        trigger = before,
                        delay = 0.2,
                        func = function()
                            v:juice_up(0.3, 0.4)
                            v:set_edition(poll_edition(pseudorandom('j_valleyOfTheKings_Set'), nil, true, true))
                            return true
                        end
                    })
                end
            end
            if done then
                delay(1)
            end
        end
    end
}

Joker {
    key = 'Mafdet',
    pos = {4, 1},
    extra = {
        xmult = 1,
        xmultg = 0.5
    },
    rarity = 3,
    cost = 7,
    credits = {{'code', 'revo'}},
    perishable_compat = false,
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.extra.xmult, card.ability.extra.xmultg}
        }
    end,
    calculate = function(self, card, context)
        if G.GAME.current_round.hands_played >= 0 and G.GAME.current_round.hands_played <= 1 and context.end_of_round and
            context.main_eval and not context.blueprint and not context.repetition then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmultg
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT
            }
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

Joker {
    key = 'Anubis',
    pos = {0, 2},
    extra = {
        mult = 0,
        multg = 5
    },
    rarity = 3,
    cost = 5,
    credits = {{'code', 'revo'}},
    perishable_compat = false,
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.extra.mult, card.ability.extra.multg}
        }
    end,
    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.scoring_hand and not context.blueprint and not context.repetition then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.multg * #context.removed
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT
            }
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end

}
-- END REGION: Jokers by Revo
