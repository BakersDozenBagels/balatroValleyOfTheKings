SMODS.Atlas {
    key = "Jokers",
    path = "Jokers.png",
    px = 71,
    py = 95
}

local function Joker(o)
    o.atlas = "Jokers"
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

    SMODS.Joker(o)
end

Joker {
    key = 'Bes',
    pos = {2, 0},
    extra = {5, 2},
    rarity = 3,
    cost = 8,
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
