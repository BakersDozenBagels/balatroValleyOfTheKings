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
        not self.debuff and next(SMODS.find_card("j_maeplThing_Isis", true)) then
        for _, v in pairs(SMODS.find_card("j_maeplThing_Isis", true)) do
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
            for _, v in pairs(SMODS.find_card("j_maeplThing_Isis", true)) do
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
