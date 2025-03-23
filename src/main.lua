SMODS.Atlas {
    key = 'Jokers',
    path = 'Jokers.png',
    px = 71,
    py = 95
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

    -- Temporary
    o.discovered = true
    o.cost = 1

    SMODS.Joker(o)
end

Joker {
    key = 'Bes',
    pos = {2, 0},
    extra = {5, 2},
    rarity = 3,
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
function maeplThing_create_card_area()
    G.maeplThing_destroyed_card_holding_zone = CardArea(-100, -100, 0, 0, {
        type = 'discard'
    })
    G.maeplThing_king_holding_zone = CardArea(-100, -100, 0, 0, {
        type = 'discard'
    })
end

local raw_Card_remove = Card.remove
function Card:remove()
    if G.maeplThing_destroyed_card_holding_zone and not self.params.maeplThing_phantom and self.playing_card and
        not self.debuff and next(SMODS.find_card('j_maeplThing_Isis', true)) then
        for _, v in pairs(SMODS.find_card('j_maeplThing_Isis', true)) do
            v.ability.extra[2] = true
        end
        local old = G.maeplThing_destroyed_card_holding_zone.cards[1]
        if old then
            old:remove()
        end
        local clone = copy_card(self)
        clone.params.maeplThing_phantom = true
        G.maeplThing_destroyed_card_holding_zone:emplace(clone)
        G.maeplThing_destroyed_card_holding_zone:hard_set_cards()
    end
    raw_Card_remove(self)
end

local function copy_to_deck(card)
    G.playing_card = (G.playing_card and G.playing_card + 1) or 1
    local clone = copy_card(card, nil, nil, G.playing_card)
    clone.params.maeplThing_phantom = nil
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
    calculate = function(self, card, context)
        if context.setting_blind and card.ability.extra[1] >= 1 and card.ability.extra[2] then
            local last_destroyed = G.maeplThing_destroyed_card_holding_zone.cards[1]
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
            for _, v in pairs(SMODS.find_card('j_maeplThing_Isis', true)) do
                if v ~= card then
                    return
                end
            end

            local old = G.maeplThing_destroyed_card_holding_zone.cards[1]
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
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card.base.value == card.ability.extra[1] and
            not card.debuff and not context.blueprint then
            local old = G.maeplThing_king_holding_zone.cards[1]
            if old then
                old:remove()
            end
            local clone = copy_card(context.other_card)
            clone.params.maeplThing_phantom = true
            G.maeplThing_king_holding_zone:emplace(clone)
            G.maeplThing_king_holding_zone:hard_set_cards()

            card.ability.extra[2] = true
        end

        if context.setting_blind and card.ability.extra[2] then
            local last_destroyed = G.maeplThing_king_holding_zone.cards[1]
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
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        return {
            vars = {G.GAME.probabilities.normal, card.ability.extra}
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.cardarea == G.jokers and not G.game_over and G.GAME.blind.boss then
            if pseudorandom('j_maeplThing_Min') < G.GAME.probabilities.normal / card.ability.extra then
                G.E_MANAGER:add_event(Event {
                    func = function()
                        local joker = copy_card(pseudorandom_element(G.jokers.cards,
                            pseudoseed('j_maeplThing_Min_choice')), nil, nil, nil, true)
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

local consumable_makers = {{'Nut', 1, 'c_high_priestess', {0, 3}}, {'Sobek', 1, 'c_lovers', {4, 2}},
                           {'Ptah', 2, 'c_world', {3, 2}}}

for _, v in ipairs(consumable_makers) do
    Joker {
        key = v[1],
        pos = v[4],
        rarity = 2,
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
                                        key_append = 'j_maeplThing_Nut',
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
