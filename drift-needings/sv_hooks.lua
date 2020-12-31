
function PLUGIN:PostPlayerLoadout( pl )
    if !IsValid( pl ) and !pl:IsPlayer() then return end
    local char = pl:GetCharacter() or false
    local _enabled = ix.config.Get( "needsEnabled", true ) or true
    if not _enabled then return end

    if char then
        if pl:_TimerExists( "ixSaturation::" .. pl:SteamID64() ) then
            pl:_RemoveTimer( "ixSaturation::" .. pl:SteamID64() )
        end

        if pl:_TimerExists( "ixSatiety::" .. pl:SteamID64() ) then
            pl:_RemoveTimer( "ixSatiety::" .. pl:SteamID64() )
        end

        if !char:GetData( "ixSaturation" ) then
            ix.Hunger:InitThirst( pl )
        end

        if !char:GetData( "ixSatiety" ) then
            ix.Hunger:InitHunger( pl )
        end

        pl:_SetTimer( "ixSaturation::" .. pl:SteamID64(), 60 * 2, 0, function()
            local bSaturation = hook.Run( "CanPlayerThirst", pl ) or true
            local _damage = ix.config.Get( "needsDamage", 2 ) or 2
            local _killing = ix.config.Get( "starvingKilling", true ) or true

            if bSaturation == true then
                local downgrade = ix.config.Get( "thirstDowngrade", 3 ) or 3
                ix.Hunger:DowngradeSaturation( pl, tonumber( downgrade ) )

                if char:GetThirst() <= 0 and _killing then
                    pl:SetHealth( math.Clamp( pl:Health() - tonumber( _damage ), 10, pl:GetMaxHealth() ) )
                end
            end
        end )

        pl:_SetTimer( "ixSatiety::" .. pl:SteamID64(), 60 * 2, 0, function()
            local bSatiety = hook.Run( "CanPlayerHunger", pl ) or true
            local _damage = ix.config.Get( "needsDamage", 2 ) or 2
            local _killing = ix.config.Get( "starvingKilling", true ) or true

            if bSatiety == true then
                local downgrade = ix.config.Get( "hungerDowngrade", 2 ) or 2
                ix.Hunger:DowngradeSatiety( pl, tonumber( downgrade ) )

                if char:GetHunger() <= 0 then
                    pl:EmitSound("npc/barnacle/barnacle_digesting2.wav", 45, 100)

                    if _killing then
                        pl:SetHealth( math.Clamp( pl:Health() - tonumber( _damage ), 10, pl:GetMaxHealth() ) )
                    end
                end
            end
        end )

        hook.Run("PlayerHungerInit", pl)
    end
end

function ix.Hunger:InitThirst( pl )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSaturation", 60 )
        end
    end
end

function ix.Hunger:InitHunger( pl )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSatiety", 60 )
        end
    end
end

function ix.Hunger:RestoreSatiety( pl, amount )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSatiety", math.Clamp(char:GetData("ixSatiety", 0) + amount, 0, 100) )
        end
    end
end

function ix.Hunger:RestoreSaturation( pl, amount )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSaturation", math.Clamp(char:GetData("ixSaturation", 0) + amount, 0, 100) )
        end
    end
end

function ix.Hunger:DowngradeSatiety( pl, amount )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSatiety", math.Clamp(char:GetData("ixSatiety", 0) - amount, 0, 100) )
        end
    end
end

function ix.Hunger:DowngradeSaturation( pl, amount )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSaturation", math.Clamp(char:GetData("ixSaturation", 0) - amount, 0, 100) )
        end
    end
end

function ix.Hunger:SetSatiety( pl, amount )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSatiety", math.Clamp(amount, 0, 100) )
        end
    end
end

function ix.Hunger:SetSaturation( pl, amount )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSaturation", math.Clamp(amount, 0, 100) )
        end
    end
end

function PLUGIN:DoPlayerDeath(pl, _, __)
    if IsValid( pl ) then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSatiety", 60 )
            char:SetData( "ixSaturation", 60 )
        end
    end
end

util.AddNetworkString( 'EnableHungerBars' )
function PLUGIN:PlayerLoadedCharacter( pl, _, __ )
    if pl:GetNetVar("hungerBarsUpdated", false) == true then return end

    net.Start( 'EnableHungerBars' )
    net.Send( pl )

    pl:SetNetVar("hungerBarsUpdated", true)
end
