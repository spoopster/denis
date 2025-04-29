DenisMod = RegisterMod("Denis", 1) ---@type ModReference
local mod = DenisMod
local sfx = SFXManager()

mod.PLAYER_DENIS = Isaac.GetPlayerTypeByName("Denis", false)

mod.COLLECTIBLE_MITOCHONDRIA = Isaac.GetItemIdByName("Mitochondria")
mod.COLLECTIBLE_AMOEBA = Isaac.GetItemIdByName("Amoeba")
mod.COLLECTIBLE_CELLPHONE = Isaac.GetItemIdByName("Cellphone")
mod.COLLECTIBLE_POWER_CELL = Isaac.GetItemIdByName("Power Cell")
mod.COLLECTIBLE_CELLO = Isaac.GetItemIdByName("Cello")
mod.COLLECTIBLE_OCELLUS = Isaac.GetItemIdByName("Ocellus")

mod.TRINKET_ANIMAL_CELL = Isaac.GetTrinketIdByName("Animal Cell")
mod.TRINKET_PLANT_CELL = Isaac.GetTrinketIdByName("Plant Cell")
mod.TRINKET_FUNGI_CELL = Isaac.GetTrinketIdByName("Fungi Cell")
mod.TRINKET_PROTIST_CELL = Isaac.GetTrinketIdByName("Protist Cell")
mod.TRINKET_PROKARYOTIC_CELL = Isaac.GetTrinketIdByName("Prokaryotic Cell")

mod.ACHIEVEMENT_MITOCHONDRIA = Isaac.GetAchievementIdByName("Denis - Mitochondria")
mod.ACHIEVEMENT_AMOEBA = Isaac.GetAchievementIdByName("Denis - Amoeba")
mod.ACHIEVEMENT_CELLPHONE = Isaac.GetAchievementIdByName("Denis - Cellphone")
mod.ACHIEVEMENT_POWER_CELL = Isaac.GetAchievementIdByName("Denis - Power Cell")
mod.ACHIEVEMENT_CELLO = Isaac.GetAchievementIdByName("Denis - Cello")
mod.ACHIEVEMENT_OCELLUS = Isaac.GetAchievementIdByName("Denis - Ocellus")
mod.ACHIEVEMENT_ANIMAL_CELL = Isaac.GetAchievementIdByName("Denis - Animal Cell")
mod.ACHIEVEMENT_PLANT_CELL = Isaac.GetAchievementIdByName("Denis - Plant Cell")
mod.ACHIEVEMENT_FUNGI_CELL = Isaac.GetAchievementIdByName("Denis - Fungi Cell")
mod.ACHIEVEMENT_PROTIST_CELL = Isaac.GetAchievementIdByName("Denis - Protist Cell")
mod.ACHIEVEMENT_PROKARYOTIC_CELL = Isaac.GetAchievementIdByName("Denis - Prokaryotic Cell")

local ACHIEVEMENT_TABLE = {
    [mod.ACHIEVEMENT_MITOCHONDRIA] = function() return Isaac.GetCompletionMark(mod.PLAYER_DENIS, CompletionType.DELIRIUM)>0 end,
    [mod.ACHIEVEMENT_AMOEBA] = function() return Isaac.GetCompletionMark(mod.PLAYER_DENIS, CompletionType.BEAST)>0 end,
    [mod.ACHIEVEMENT_CELLPHONE] = function() return Isaac.GetCompletionMark(mod.PLAYER_DENIS, CompletionType.ULTRA_GREED)>0 end,
    [mod.ACHIEVEMENT_POWER_CELL] = function() return Isaac.GetCompletionMark(mod.PLAYER_DENIS, CompletionType.HUSH)>0 end,
    [mod.ACHIEVEMENT_CELLO] = function() return Isaac.GetCompletionMark(mod.PLAYER_DENIS, CompletionType.ULTRA_GREED)>=2 end,
    [mod.ACHIEVEMENT_OCELLUS] = function() return Isaac.GetCompletionMark(mod.PLAYER_DENIS, CompletionType.MOTHER)>0 end,
    [mod.ACHIEVEMENT_ANIMAL_CELL] = function() return Isaac.GetCompletionMark(mod.PLAYER_DENIS, CompletionType.SATAN)>0 end,
    [mod.ACHIEVEMENT_PLANT_CELL] = function() return Isaac.GetCompletionMark(mod.PLAYER_DENIS, CompletionType.ISAAC)>0 end,
    [mod.ACHIEVEMENT_FUNGI_CELL] = function() return Isaac.GetCompletionMark(mod.PLAYER_DENIS, CompletionType.LAMB)>0 end,
    [mod.ACHIEVEMENT_PROTIST_CELL] = function() return Isaac.GetCompletionMark(mod.PLAYER_DENIS, CompletionType.BLUE_BABY)>0 end,
    [mod.ACHIEVEMENT_PROKARYOTIC_CELL] = function() return Isaac.GetCompletionMark(mod.PLAYER_DENIS, CompletionType.BOSS_RUSH)>0 end,
}

local function checkUnlocks(blockPaper)
    for ach, condition in pairs(ACHIEVEMENT_TABLE) do
        if(condition()) then
            Isaac.GetPersistentGameData():TryUnlock(ach, blockPaper)
        else
            Isaac.ExecuteCommand("lockachievement " .. ach)
        end
    end
end

local function checkUnlocksOnInit(_)
    checkUnlocks(false)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, checkUnlocksOnInit)

local function checkUnlocksOnCompletion(_, mark)
    checkUnlocks(false)
end
mod:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, checkUnlocksOnCompletion)

--#region DENIS CHARACTER

local MINISAAC_NUM_COSTUMES = 8
local DENIS_CHARGEBAR_GFX = "gfx/ui/denis_chargebar.anm2"

local MINISAAC_WEAPON_CHANCE = 0.5
local MINISAAC_FLAGS_CHANCE = 1--0.5

local MINISAAC_BASE_DMG_MULT = 0.75
local MINISAAC_DMG_MULT = 0.3/MINISAAC_BASE_DMG_MULT
local MINISAAC_THROWN_DMG = 6

local DENIS_SUMMON_DURATION = 60*1.5
local DENIS_BIRTHRIGHT_LUCKBOOST = 5
local DENIS_COLOR = Color(1.8,1.8,2.2,1)

local VALID_WEAPONTYPES = {
    [WeaponType.WEAPON_TEARS] = true,
    [WeaponType.WEAPON_BRIMSTONE] = true,
    [WeaponType.WEAPON_LASER] = true,
    [WeaponType.WEAPON_KNIFE] = true,
    [WeaponType.WEAPON_BOMBS] = true,
    [WeaponType.WEAPON_MONSTROS_LUNGS] = true,
    [WeaponType.WEAPON_TECH_X] = true,
}

local SAVED_SEEDS = {}

---@param pl EntityPlayer
---@param fam EntityFamiliar
local function tryHoldMinisaac(pl, fam)
    fam.SpriteOffset.Y = 0

    fam.Variant = FamiliarVariant.CUBE_BABY
    pl:TryHoldEntity(fam)
    fam.Variant = FamiliarVariant.MINISAAC
end

---@param weaponType WeaponType
---@param flags TearFlags
---@param addWeapon boolean
---@param addFlags boolean
local function getSeed(weaponType, flags, addWeapon, addFlags)
    if((weaponType==WeaponType.WEAPON_TEARS or not addWeapon) and (flags==TearFlags.TEAR_NORMAL or not addFlags)) then return -1 end

    local hashRng = RNG(Game():GetSeeds():GetStartSeed())

    local maxVal = 2^32-1
    local startSeed = hashRng:RandomInt(maxVal)

    if(addWeapon and weaponType~=WeaponType.WEAPON_TEARS) then
        startSeed = (startSeed+weaponType*hashRng:RandomInt(21211))%maxVal
    end

    if(addFlags and flags~=TearFlags.TEAR_NORMAL) then
        for i=1,127 do
            local val = hashRng:RandomInt(3361)
            if(flags:Get(i)) then
                startSeed = startSeed+val*i
            end
        end
        startSeed = startSeed%maxVal
    end

    return (startSeed+1)//1
end

---@param seed integer
local function getDenisSkinData(seed)
    local rng = RNG(seed)

    local skinColor = Color(rng:RandomFloat(), rng:RandomFloat(), rng:RandomFloat(), 1)
    local costumeColor = Color(rng:RandomFloat(), rng:RandomFloat(), rng:RandomFloat(), 1)

    return {
        SkinColor = skinColor,
        CostumeColor = costumeColor,
        CostumeID = rng:RandomInt(MINISAAC_NUM_COSTUMES)+1,
    }
end

---@param pl EntityPlayer
---@param fam EntityFamiliar
local function initDenisMinisaac(pl, fam)
    local data = fam:GetData()

    local keyStr = tostring(fam.InitSeed)

    if(not SAVED_SEEDS[keyStr]) then
        local rng = RNG(math.max(fam.InitSeed, 1))

        local weap = pl:GetWeapon(1)
        local weapType = (weap and weap:GetWeaponType() or WeaponType.WEAPON_TEARS)
        if(not VALID_WEAPONTYPES[weapType]) then
            weapType = WeaponType.WEAPON_TEARS
        end

        local ogLuck = pl.Luck
        local hasBirthright = (pl:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and pl:GetPlayerType()==mod.PLAYER_DENIS)
        if(hasBirthright) then
            pl.Luck = pl.Luck+DENIS_BIRTHRIGHT_LUCKBOOST
        end

        local tearHitParams = pl:GetTearHitParams(weapType, 1, 1, pl)

        if(hasBirthright) then
            pl.Luck = ogLuck
        end

        local tearFlags = tearHitParams.TearFlags

        local useWeap = (rng:RandomFloat()<MINISAAC_WEAPON_CHANCE)
        local useFlags = (rng:RandomFloat()<MINISAAC_FLAGS_CHANCE)
        
        local hashedSeed = getSeed(weapType, tearFlags, useWeap, useFlags)

        --[[
        local usedFlags = ""
        for key, val in pairs(TearFlags) do
            if(tearFlags & val == val) then
                usedFlags = usedFlags..key.." "
            end
        end

        
        print("SEED:", hashedSeed)
        print("WEAPON:", weapType)
        print("FLAGS:", tearFlags)
        print("FLAGS (keys):", usedFlags)
        print("Using weapon:", useWeap)
        print("Using flags:", useFlags)

        print("---")
        --]]

        SAVED_SEEDS[keyStr] = {
            Seed = hashedSeed,
            WeaponType = (useWeap and weapType or WeaponType.WEAPON_TEARS),
            FlagsLow = (useFlags and tearFlags.l or 0),
            FlagsHigh = (useFlags and tearFlags.h or 0),
            TearColor = (useFlags and tearHitParams.TearColor or Color.Default),
            MinisaacType = "DEFAULT",
            StorageNumberVariableIDontWantToName = -1,
        }
    end

    local savedData = SAVED_SEEDS[keyStr]

    --print(savedData.Seed, savedData.WeaponType, savedData.FlagsLow, savedData.FlagsHigh)

    local skinData
    if(savedData.Seed==-1) then
        skinData = {
            SkinColor = Color(155/255, 194/255, 1, 1),
            CostumeColor = Color(1,1,1,1),
            CostumeID = 0,
        }
    else
        skinData = getDenisSkinData(savedData.Seed)
    end

    local sp = fam:GetSprite()
    local anim, frame = sp:GetAnimation(), sp:GetFrame()
    local overlayAnim, overlayFrame = sp:GetOverlayAnimation(), sp:GetOverlayFrame()

    local costumePath = "gfx/familiar/denis_minisaac_costume"..tostring((skinData.CostumeID or 0)+1)..".png"

    sp:Load("gfx/familiar/denis_minisaac.anm2", false)
    sp:ReplaceSpritesheet(4, costumePath)
    sp:ReplaceSpritesheet(5, costumePath)
    sp:LoadGraphics()

    sp:SetFrame(anim, frame)
    sp:SetOverlayFrame(overlayAnim, overlayFrame)

    sp:GetLayer(2):SetColor(skinData.SkinColor)
    sp:GetLayer(3):SetColor(skinData.SkinColor)
    sp:GetLayer(4):SetColor(skinData.CostumeColor)
    sp:GetLayer(5):SetColor(skinData.CostumeColor)

    local shouldCopyPlayer = false
    if(savedData.MinisaacType=="DEFAULT" or savedData.MinisaacType=="AMOEBA") then
        shouldCopyPlayer = true
    end

    local isInvincible = false
    if(savedData.MinisaacType=="AMOEBA") then
        isInvincible = true
    end

    local dmgMult = MINISAAC_DMG_MULT
    if(savedData.MinisaacType=="MITOCHONDRIA") then
        dmgMult = savedData.StorageNumberVariableIDontWantToName
    end

    data.DenisMinisaacData = {
        Seed = savedData.Seed,
        GuaranteedFlags = BitSet128(savedData.FlagsLow, savedData.FlagsHigh),
        WeaponType = savedData.WeaponType,
        MinisaacType = savedData.MinisaacType,
        TearColor = savedData.TearColor,

        DamageMult = dmgMult,
        CopyPlayer = shouldCopyPlayer,

        SkinColor = skinData.SkinColor,
        CostumeColor = skinData.CostumeColor,
        CostumeID = skinData.CostumeID,

        Invincible = isInvincible,
    }
end

---@param pl EntityPlayer
local function denisUpdate(_, pl)
    if(pl:GetPlayerType()~=mod.PLAYER_DENIS) then return end
    pl.Color = DENIS_COLOR

    local data = pl:GetData()
    data.DenisCharge = data.DenisCharge or 0

    if(Input.IsActionTriggered(ButtonAction.ACTION_DROP, pl.ControllerIndex)) then
        local heldEnt = pl:GetHeldEntity()
        if(heldEnt and heldEnt:ToFamiliar() and heldEnt:ToFamiliar().Variant==FamiliarVariant.MINISAAC) then
            pl:ThrowHeldEntity(Vector.Zero)
        elseif(heldEnt==nil and pl:GetItemState()==0) then
            local plHash = GetPtrHash(pl)
            local nearMinisaac
            for _, fam in ipairs(Isaac.FindInRadius(pl.Position, 40, EntityPartition.FAMILIAR)) do
                if(fam.Variant==FamiliarVariant.MINISAAC and GetPtrHash(fam:ToFamiliar().Player)==plHash) then
                    nearMinisaac = fam
                    break
                end
            end

            if(nearMinisaac) then
                data.DenisCharge = 0
                tryHoldMinisaac(pl, nearMinisaac:ToFamiliar())
            end
        end
    end


    if(pl:GetHeldEntity()==nil and pl:GetItemState()==0) then
        if(pl:GetFireDirection()~=Direction.NO_DIRECTION or pl:GetShootingInput():Length()>0.01) then
            if(data.DenisCharge<DENIS_SUMMON_DURATION) then
                data.DenisCharge = data.DenisCharge+1
            else
                data.DenisCharge = 0

                local plHash = GetPtrHash(pl)
                local maxMinisaacNum = math.ceil(30/(pl.MaxFireDelay+1))
                local numMinisaacs = 0
                local oldestMinisaac, oldestMinisaacFrames = nil, -1

                for _, fam in ipairs(Isaac.FindByType(3,FamiliarVariant.MINISAAC)) do
                    if(GetPtrHash(fam:ToFamiliar().Player)==plHash) then
                        numMinisaacs = numMinisaacs+1

                        if(fam.FrameCount>oldestMinisaacFrames) then
                            oldestMinisaac = fam
                            oldestMinisaacFrames = fam.FrameCount
                        end
                    end
                end

                local newMinisaac = pl:AddMinisaac(pl.Position, false)
                newMinisaac:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                tryHoldMinisaac(pl, newMinisaac)
                sfx:Play(SoundEffect.SOUND_BLOODSHOOT)

                if(numMinisaacs>=maxMinisaacNum and oldestMinisaac) then
                    oldestMinisaac:Die()
                end
            end
        else
            data.DenisCharge = 0
        end
    else
        data.DenisCharge = 0
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, denisUpdate, PlayerVariant.PLAYER)

---@param pl EntityPlayer
---@param offset Vector
local function renderDenisChargebar(_, pl, offset)
    if(pl:GetPlayerType()~=mod.PLAYER_DENIS) then return end
    if(Options.ChargeBars==false) then return end

    local charge = pl:GetData().DenisCharge or 0
    local barOffset = Vector(-19,-30)+offset-Game():GetRoom():GetRenderScrollOffset()
    if(charge>0) then
        mod:renderCustomChargebar(pl, DENIS_CHARGEBAR_GFX, barOffset, charge/DENIS_SUMMON_DURATION, false)
    else
        mod:renderCustomChargebar(pl, DENIS_CHARGEBAR_GFX, barOffset, 0, true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, renderDenisChargebar, PlayerVariant.PLAYER)

---@param pl EntityPlayer
---@param ent Entity
---@param vel Vector
local function postThrowMinisaac(_, pl, ent, vel)
    if(pl:GetPlayerType()~=mod.PLAYER_DENIS) then return end

    if(ent and ent:ToFamiliar() and ent.Variant==FamiliarVariant.MINISAAC) then
        local tear = Isaac.Spawn(2,7247,0,pl.Position,vel,nil):ToTear() ---@cast tear EntityTear
        tear.Visible = false
        tear.FallingAcceleration = 0.65
        tear.FallingSpeed = -5
        tear:AddTearFlags(TearFlags.TEAR_PIERCING)

        tear.CollisionDamage = MINISAAC_THROWN_DMG

        ent:GetData().DenisMinisaacThrownTear = tear
        ent:AddEntityFlags(EntityFlag.FLAG_THROWN)
        ent:ClearEntityFlags(EntityFlag.FLAG_HELD)

        sfx:Play(SoundEffect.SOUND_TEARS_FIRE, 0, 2)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_THROW, postThrowMinisaac)

---@param fam EntityFamiliar
local function denisMinisaacInit(_, fam)
    local pl = fam.Player
    if(not (pl:GetPlayerType()==mod.PLAYER_DENIS or SAVED_SEEDS[tostring(fam.InitSeed)])) then return end

    initDenisMinisaac(pl, fam)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, denisMinisaacInit, FamiliarVariant.MINISAAC)

---@param fam EntityFamiliar
local function assignPlayerForMinisaac(_, fam)
    local saveData = SAVED_SEEDS[tostring(fam.InitSeed)]
    if(not saveData) then return end

    local sp = fam.SpawnerEntity
    if(not (sp and sp:ToPlayer())) then return end
    sp = sp:ToPlayer() ---@cast sp EntityPlayer
    fam.Player = sp
    fam.Parent = sp
end
mod:AddPriorityCallback(ModCallbacks.MC_FAMILIAR_INIT, CallbackPriority.IMPORTANT, assignPlayerForMinisaac, FamiliarVariant.MINISAAC)

---@param fam EntityFamiliar
---@param pl EntityPlayer
---@param posVel PosVel
---@param dir Vector
---@param weapType WeaponType
---@param forcedFlags TearFlags
---@param forcedCol Color
---@param dmgMult number
local function tryFireWeapon(fam, pl, posVel, dir, weapType, forcedFlags, forcedCol, dmgMult)
    local ogFlags = pl.TearFlags
    local ogCol = pl.TearColor
    pl.TearFlags = pl.TearFlags | forcedFlags
    pl.TearColor = forcedCol

    local ogLuck = pl.Luck
    local hasBirthright = (pl:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and pl:GetPlayerType()==mod.PLAYER_DENIS)

    if(hasBirthright) then
        pl.Luck = pl.Luck+DENIS_BIRTHRIGHT_LUCKBOOST
    end

    if(weapType==WeaponType.WEAPON_TEARS) then
        local tear = pl:FireTear(posVel.Position+fam.Position, posVel.Velocity, true, true, false, fam, dmgMult)
        tear.Scale = tear.Scale*0.75
    elseif(weapType==WeaponType.WEAPON_BRIMSTONE) then
        local laser = pl:FireBrimstone(dir, fam, dmgMult/5)
        laser.Parent = fam
        laser.PositionOffset = Vector(0,-15)
        laser:SetDamageMultiplier(dmgMult)

        fam.FireCooldown = fam.FireCooldown*4
    elseif(weapType==WeaponType.WEAPON_LASER) then
        local laser = pl:FireTechLaser(posVel.Position+fam.Position, LaserOffset.LASER_TECH5_OFFSET, dir, true, true, fam, dmgMult)
        laser.Parent = fam
        laser.PositionOffset = Vector(0, -15)
        --laser:SetDamageMultiplier(dmgMult)
    elseif(weapType==WeaponType.WEAPON_KNIFE) then
        local knife = pl:FireKnife(fam)
        knife.Parent = fam
        knife.Rotation = dir:GetAngleDegrees()
        knife.Scale = 0.5
        knife:Shoot(1, pl.TearRange*0.6)

        knife:GetData().DenisMinisaacKnife = true

        fam.FireCooldown = math.floor(pl.TearRange/6+9)
    elseif(weapType==WeaponType.WEAPON_BOMBS) then
        local bomb = pl:FireBomb(posVel.Position+fam.Position, posVel.Velocity, fam)
        bomb.ExplosionDamage = bomb.ExplosionDamage*dmgMult
        bomb:SetScale(bomb:GetScale()*dmgMult)
        bomb:SetLoadCostumes(true)
        bomb.RadiusMultiplier = bomb.RadiusMultiplier*dmgMult

        fam.FireCooldown = fam.FireCooldown*2
    elseif(weapType==WeaponType.WEAPON_MONSTROS_LUNGS) then
        for i=1, 14 do
            local rng = fam:GetDropRNG()

            local tear = pl:FireTear(posVel.Position+fam.Position, posVel.Velocity:Rotated(rng:RandomInt(-10,10)), true, true, false, fam, dmgMult)
            tear.Scale = tear.Scale*0.75*(rng:RandomFloat()*0.43+0.9)
            tear.FallingAcceleration = tear.FallingAcceleration+(rng:RandomFloat()*0.8+0.5)
            tear.FallingSpeed = tear.FallingSpeed+(rng:RandomFloat()*15-20)
        end

        fam.FireCooldown = fam.FireCooldown*5
    elseif(weapType==WeaponType.WEAPON_TECH_X) then
        local dmg = pl.Damage
        pl.Damage = pl.Damage*dmgMult

        local laser = pl:FireTechXLaser(posVel.Position+fam.Position, posVel.Velocity, 40, fam, 1)

        pl.Damage = dmg

        fam.FireCooldown = fam.FireCooldown*3
    end

    if(hasBirthright) then
        pl.Luck = ogLuck
    end

    pl.TearFlags = ogFlags
    pl.TearColor = ogCol
end

---@param fam EntityFamiliar
local function minisaacUpdate(_, fam)
    local pl = fam.Player
    local data = fam:GetData()

    if(fam:HasEntityFlags(EntityFlag.FLAG_HELD)) then
        fam.SizeMulti = Vector.Zero
        return true
    elseif(fam:HasEntityFlags(EntityFlag.FLAG_THROWN)) then --- THROWN
        fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    
        if(data.DenisMinisaacThrownTear and data.DenisMinisaacThrownTear:Exists()) then
            fam.SizeMulti = Vector.Zero
            fam.Position = data.DenisMinisaacThrownTear.Position
            fam.Velocity = data.DenisMinisaacThrownTear.Velocity
            fam.SpriteOffset = Vector(0, data.DenisMinisaacThrownTear.Height+5)

            local animDirections = {"Down","Left","Up","Right"}
            local selFrame = animDirections[(fam.FrameCount//3)%4+1]
            
            local sp = fam:GetSprite()

            sp:SetFrame((pl.CanFly and "Fly" or "Walk")..selFrame, 0)
            sp:SetOverlayFrame("Head"..selFrame, 0)
        else
            fam:ClearEntityFlags(EntityFlag.FLAG_THROWN)
            data.DenisMinisaacThrownTear = nil

            fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            fam.GridCollisionClass = (pl.CanFly and EntityGridCollisionClass.GRIDCOLL_WALLS or EntityGridCollisionClass.GRIDCOLL_GROUND)
        end

        return true
    elseif(data.DenisMinisaacData) then --- IDLE
        fam.SpriteOffset.Y = fam.SpriteOffset.Y*0.6
    
        if(fam.FireCooldown==0 and fam.Target and data.DenisMinisaacData.CopyPlayer) then --- IF IS FIRING
            fam.FireCooldown = 9

            local dir = (fam.Target.Position-fam.Position):Normalized()

            local oldPos, oldVel = pl.Position, pl.Velocity
            pl.Position = fam.Position
            pl.Velocity = fam.Velocity

            local weapType = data.DenisMinisaacData.WeaponType or (pl:GetWeapon(1) and pl:GetWeapon(1):GetWeaponType() or WeaponType.WEAPON_TEARS)
            local forceFlags = data.DenisMinisaacData.GuaranteedFlags or TearFlags.TEAR_NORMAL
            local forceColor = data.DenisMinisaacData.TearColor or Color.Default
            local dmgMult = data.DenisMinisaacData.DamageMult or MINISAAC_DMG_MULT

            local multishotParams = pl:GetMultiShotParams(weapType)

            for i=1, multishotParams:GetNumTears() do
                local posVel = pl:GetMultiShotPositionVelocity(i-1, weapType, dir, pl.ShotSpeed*8, multishotParams)

                tryFireWeapon(fam, pl, posVel, dir, weapType, forceFlags, forceColor, dmgMult)
            end

            pl.Position = oldPos
            pl.Velocity = oldVel

            return true
        end
    elseif(pl:GetPlayerType()==mod.PLAYER_DENIS) then
        fam.SpriteOffset.Y = fam.SpriteOffset.Y*0.6
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_UPDATE, minisaacUpdate, FamiliarVariant.MINISAAC)

---@param knife EntityKnife
local function killDenisKnife(_, knife)
    if(not knife:GetData().DenisMinisaacKnife) then return end

    if(knife:GetKnifeDistance()<5) then knife:Remove() end
end
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, killDenisKnife)

---@param ent Entity
---@param dmg number
---@param flags DamageFlag
---@param sourceRef EntityRef
---@param count integer
local function denisDecreaseDamage(_, ent, dmg, flags, sourceRef, count)
    local source = sourceRef.Entity
    if(source and source:ToKnife() and source:GetData().DenisMinisaacKnife) then
        return {
            Damage = dmg*MINISAAC_DMG_MULT*0.7,
            DamageFlags = flags,
            DamageCountdown = count,
        }
    end

    if(ent.Type==EntityType.ENTITY_FAMILIAR and ent.Variant==FamiliarVariant.MINISAAC) then
        local miniData = ent:GetData().DenisMinisaacData
        if(miniData and miniData.Invincible) then
            return false
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, denisDecreaseDamage)

--#endregion

--#region MITOCHONDRIA ITEM

local MINISAAC_DAMAGE_MULT_PER_CHARGE = 1/6 -- 16% dmg for 1 charge, 200% dmg for 12 charges
local MINISAAC_ABNORMAL_CHARGE_MULT = 0.1 -- for timed/special items
local MINISAAC_MICRO_BATTERY_CHANCE = 0.25

local function trySpawnMinisaac(pl, item)
    local conf = Isaac.GetItemConfig():GetCollectible(item)
    local mult = MINISAAC_ABNORMAL_CHARGE_MULT
    if(conf.ChargeType==ItemConfig.CHARGE_NORMAL) then
        mult = MINISAAC_DAMAGE_MULT_PER_CHARGE*conf.MaxCharges
    end

    local seed = pl:GetCollectibleRNG(item):RandomInt(2^32-1)+1
    SAVED_SEEDS[tostring(seed)] = {
        Seed = RNG(math.max(1,seed)):RandomInt(2^32-1)+1,
        WeaponType = nil,
        FlagsLow = 0,
        FlagsHigh = 0,
        MinisaacType = "MITOCHONDRIA",

        StorageNumberVariableIDontWantToName = mult,
    }

    local minisaac = Game():Spawn(3,FamiliarVariant.MINISAAC,pl.Position,Vector.Zero,pl,0,seed):ToFamiliar() ---@cast minisaac EntityFamiliar
    minisaac:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    minisaac.State = 1
    minisaac:GetSprite():Play("Appear", true)
    minisaac:GetSprite():RemoveOverlay()
end

--- VANILLA/MODDED NON-THROWABLE ITEMS
--- PROBABLY BREAKS IN SOME SITUATIONS AS IT JUST CHECKS WHETHER ITEM CHARGE IS LOWER THAN IN PRE_USE_ITEM

---@param id CollectibleType
---@param pl EntityPlayer
local function blablabla(_, id, rng, pl, flags, slot, vardata)
    if(not pl:HasCollectible(mod.COLLECTIBLE_MITOCHONDRIA)) then return end

    local data = pl:GetData()

    data.DenisMitochondriaItemQueue = data.DenisMitochondriaItemQueue or {}
    table.insert(data.DenisMitochondriaItemQueue, {id,slot,flags,pl:GetTotalActiveCharge(slot)})
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_USE_ITEM, math.huge, blablabla)

---@param pl EntityPlayer
local function nonThrowableReroll(_, pl)
    if(not pl:HasCollectible(mod.COLLECTIBLE_MITOCHONDRIA)) then
        pl:GetData().DenisMitochondriaItemQueue = nil

        return
    end

    local data = pl:GetData()
    if(not data.DenisMitochondriaItemQueue) then return end

    for _, itemData in ipairs(data.DenisMitochondriaItemQueue) do
        local currentCharge = pl:GetTotalActiveCharge(itemData[2])
        if(currentCharge<itemData[4]) then
            trySpawnMinisaac(pl, itemData[1])
        end
    end

    data.DenisMitochondriaItemQueue = nil
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, nonThrowableReroll)


--- VANILLA THROWABLE ITEMS
--- BIT JANKY (DELAYED REROLL)

local vanillaThrowables = {
    [CollectibleType.COLLECTIBLE_DECAP_ATTACK] = 1,
    [CollectibleType.COLLECTIBLE_ERASER] = 1,
    [CollectibleType.COLLECTIBLE_SHARP_KEY] = 1,
    [CollectibleType.COLLECTIBLE_GLASS_CANNON] = 1,
    [CollectibleType.COLLECTIBLE_BOOMERANG] = 1,
    [CollectibleType.COLLECTIBLE_RED_CANDLE] = 1,
    [CollectibleType.COLLECTIBLE_CANDLE] = 1,
    [CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD] = 1,
}

---@param pl EntityPlayer
local function vanillaThrowableItemReroll(_, pl)
    local data = pl:GetData()
    local state = pl:GetItemState()
    data.DenisMitochondriaItemState = data.DenisMitochondriaItemState or state

    if(state==0 and data.DenisMitochondriaItemState~=0 and pl:HasCollectible(mod.COLLECTIBLE_MITOCHONDRIA)) then
        local isntPickupAnim = (string.find(pl:GetSprite():GetAnimation(), "PickupWalk")==nil)
        if(isntPickupAnim and vanillaThrowables[data.DenisMitochondriaItemState]) then
            trySpawnMinisaac(pl, data.DenisMitochondriaItemState)
        end
    end

    data.DenisMitochondriaItemState = state
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, vanillaThrowableItemReroll)


--- MODDED THROWABLE ITEMS
--- MODIFIES METATABLE TO TRY AND REROLL WHEN player:DischargeActiveItem(slot) IS CALLED

local ogMetaTable = getmetatable(EntityPlayer).__class
local newMetaTable = {}
local ogIndex = ogMetaTable.__index

function newMetaTable:DischargeActiveItem(slot)
    if(self:HasCollectible(mod.COLLECTIBLE_MITOCHONDRIA)) then
        trySpawnMinisaac(self, self:GetActiveItem(slot))
    end

    ogMetaTable.DischargeActiveItem(self, slot)
end

rawset(ogMetaTable, "__index",
    function(self, key)
        if(newMetaTable[key]) then
            return newMetaTable[key]
        else
            return ogIndex(self, key)
        end
    end
)

---@param tear EntityTear
local function mitochondriaLateTearInit(_, tear)
    if(tear.FrameCount~=0) then return end
    
    local spawner = tear.SpawnerEntity
    if(not (spawner and spawner.Type==3 and spawner.Variant==FamiliarVariant.MINISAAC)) then return end

    local data = spawner:GetData().DenisMinisaacData
    if( data and data.MinisaacType=="MITOCHONDRIA") then
        tear.CollisionDamage = tear.CollisionDamage*(data.DamageMult or 1)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mitochondriaLateTearInit)

---@param ent Entity
local function postMinisaacDeath(_, ent)
    if(ent.Variant~=FamiliarVariant.MINISAAC) then return end

    if(PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE_MITOCHONDRIA)) then
        local rng = PlayerManager.FirstCollectibleOwner(mod.COLLECTIBLE_MITOCHONDRIA):GetCollectibleRNG(mod.COLLECTIBLE_MITOCHONDRIA)
        if(rng:RandomFloat()<MINISAAC_MICRO_BATTERY_CHANCE) then
            local microBattery = Isaac.Spawn(5,PickupVariant.PICKUP_LIL_BATTERY,BatterySubType.BATTERY_MICRO,ent.Position,Vector.Zero,nil):ToPickup()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, postMinisaacDeath, EntityType.ENTITY_FAMILIAR)

--#endregion

--#region AMOEBA ITEM

---@param pl EntityPlayer
---@param flags UseFlag
local function useAmoeba(_, _, rng, pl, flags, slot, vardata)
    for _, ent in ipairs(Isaac.FindByType(5,100)) do
        local pickup = ent:ToPickup() ---@cast pickup EntityPickup
        if(pickup and not pickup:IsShopItem()) then

            local seed = rng:RandomInt(2^32-1)+1
            SAVED_SEEDS[tostring(seed)] = {
                Seed = RNG(math.max(1,seed)):RandomInt(2^32-1)+1,
                WeaponType = nil,
                FlagsLow = 0,
                FlagsHigh = 0,
                MinisaacType = "AMOEBA",
            }

            local spawnPos = pickup.Position

            local minisaac = Game():Spawn(3,FamiliarVariant.MINISAAC,spawnPos,Vector.Zero,pl,0,seed):ToFamiliar() ---@cast minisaac EntityFamiliar
            minisaac:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

            minisaac.State = 1
            minisaac:GetSprite():Play("Appear", true)
            minisaac:GetSprite():RemoveOverlay()

            pickup:Remove()
            local poof = Isaac.Spawn(1000,15,0,spawnPos,Vector.Zero,nil):ToEffect()
        end
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, useAmoeba, mod.COLLECTIBLE_AMOEBA)

--#endregion

--#region CELLPHONE ITEM

local CELLPHONE_CONTACT_USES = 3

---@param pl EntityPlayer
---@param flags UseFlag
local function useCellphone(_, _, rng, pl, flags, slot, vardata)
    for _=1, CELLPHONE_CONTACT_USES do
        pl:UseCard(Card.CARD_EMERGENCY_CONTACT, flags | UseFlag.USE_NOANNOUNCER)
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, useCellphone, mod.COLLECTIBLE_CELLPHONE)

--#endregion

--#region POWER CELL ITEM

local POWERCELL_DAMAGE_MULT = 1.5
local POWERCELL_PROC_HEARTS = 3

---@param pl EntityPlayer
local function powerCellCache(_, pl, flag)
    if(not pl:HasCollectible(mod.COLLECTIBLE_POWER_CELL)) then return end

    pl.Damage = pl.Damage*POWERCELL_DAMAGE_MULT
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, powerCellCache, CacheFlag.CACHE_DAMAGE)

---@param pl EntityPlayer
local function powerCellUpdate(_, pl)
    if(not pl:HasCollectible(mod.COLLECTIBLE_POWER_CELL)) then return end

    local hp = pl:GetHearts()/2+pl:GetSoulHearts()/2+pl:GetBoneHearts()
    if(hp<POWERCELL_PROC_HEARTS) then
        pl:AddBrokenHearts(1)
        while(pl:HasCollectible(mod.COLLECTIBLE_POWER_CELL)) do
            pl:RemoveCollectible(mod.COLLECTIBLE_POWER_CELL)
        end

        sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
        pl:AnimateSad()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, powerCellUpdate, PlayerVariant.PLAYER)

--#endregion

--#region CELLO

local CELLO_LOW_MULT = 0.75
local CELLO_HIGH_MULT = 3*CELLO_LOW_MULT

local CELLO_LOW_DURATION = 30*4
local CELLO_HIGH_DURATION = 30*2

---@param pl EntityPlayer
local function celloUpdate(_, pl)
    if(not pl:HasCollectible(mod.COLLECTIBLE_CELLO)) then return end

    local modulo = pl.FrameCount%(CELLO_LOW_DURATION+CELLO_HIGH_DURATION)
    if(modulo==0 or modulo==CELLO_LOW_DURATION) then
        pl:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, celloUpdate)

---@param pl EntityPlayer
---@param flag CacheFlag
local function celloCache(_, pl, flag)
    if(not pl:HasCollectible(mod.COLLECTIBLE_CELLO)) then return end

    local modulo = pl.FrameCount%(CELLO_LOW_DURATION+CELLO_HIGH_DURATION)
    if(modulo<CELLO_LOW_DURATION) then
        pl.MaxFireDelay = pl.MaxFireDelay/CELLO_LOW_MULT
    else
        pl.MaxFireDelay = pl.MaxFireDelay/CELLO_HIGH_MULT
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, celloCache, CacheFlag.CACHE_FIREDELAY)

--#endregion

--#region OCELLUS

local OCELLUS_BACK_ANGLE = 120

local function angleDifference(a1, a2)
    local dif = (a2-a1)%360
    if(dif>180) then return dif-360 end
    return dif
end
local function dir2Angle(x)
    if(x==Direction.DOWN) then return 90
    elseif(x==Direction.LEFT) then return 180
    elseif(x==Direction.UP) then return 270
    else return 0 end
end

---@param pl EntityPlayer
local function ocellusPlayerPetrify(_, pl)
    if(not pl:HasCollectible(mod.COLLECTIBLE_OCELLUS)) then return end

    local dir = Direction.DOWN
    if(pl:GetFireDirection()~=Direction.NO_DIRECTION) then
        dir = pl:GetFireDirection()
    elseif(pl:GetMovementDirection()~=Direction.NO_DIRECTION) then
        dir = pl:GetMovementDirection()
    end

    local plRef = EntityRef(pl)
    local angle = dir2Angle(dir)
    for _, ent in ipairs(Isaac.FindInRadius(pl.Position, 800, EntityPartition.ENEMY)) do
        local npc = ent:ToNPC()
        if(npc and npc:IsEnemy() and npc:IsActiveEnemy(false) and npc:IsVulnerableEnemy() and (npc:GetEntityFlags() & (EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY) == 0)) then
            local enemyAngle = (npc.Position-pl.Position):GetAngleDegrees()
            local dif = angleDifference(angle, enemyAngle)
            dif = 180-math.abs(dif)

            if(dif<=OCELLUS_BACK_ANGLE) then
                npc:AddFreeze(plRef, 1, true)
                npc:SetColor(Color(1,0.8,0.8,1,0.15,0.05,0.05,0.9,0.6,0.6,1),2,5,false,false)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ocellusPlayerPetrify, PlayerVariant.PLAYER)

--#endregion

--#region CELL TRINKETS

local ANIMALCELL_BLOOD_FREQ = 3
local ANIMALCELL_BLOOD_DMG = 4
local ANIMALCELL_BLOOD_TIMEOUT = math.floor(30*0.75)
local ANIMALCELL_DMGMULT = 1.5

local PLANTCELL_POISON_CHANCE = 0.1

local FUNGICELL_NUM = 3
local FUNGICELL_DMGMULT = 0.5

local PROTISTCELL_CONFUSE_CHANCE = 0.1

local PROKARYOTICCELL_WEAKNESS_CHANCE = 0.05
local PROKARYOTICCELL_WEAKNESS_DUR = 30*5

local forcedCellBodyColors = {
    ANIMAL = Color(193/255, 92/255, 92/255, 1),
    PLANT = Color(84/255, 132/255, 69/255, 1),
    FUNGI = Color(177/255, 153/255, 126/255, 1),
    PROTIST = Color(159/255, 180/255, 87/255, 1),
    PROKARYOTIC = Color(54/255, 220/255, 128/255, 1),
}

---@param pl EntityPlayer
---@param rng RNG
---@param cellType string
---@param amount integer
local function spawnCellMinisaac(pl, rng, cellType, amount)
    if(amount<=0) then return end

    for _=1, amount do
        local seed = rng:RandomInt(2^32-1)+1
        SAVED_SEEDS[tostring(seed)] = {
            Seed = RNG(math.max(1,seed)):RandomInt(2^32-1)+1,
            WeaponType = nil,
            FlagsLow = 0,
            FlagsHigh = 0,
            MinisaacType = cellType,
        }

        local spawnPos = Game():GetRoom():FindFreePickupSpawnPosition(pl.Position, 30)

        local minisaac = Game():Spawn(3,FamiliarVariant.MINISAAC,spawnPos,Vector.Zero,pl,0,seed):ToFamiliar() ---@cast minisaac EntityFamiliar
        minisaac:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

        minisaac.State = 1
        minisaac:GetSprite():Play("Appear", true)
        minisaac:GetSprite():RemoveOverlay()
    end
end

---@param fam EntityFamiliar
local function cellMinisaacInit(_, fam)
    local data = fam:GetData().DenisMinisaacData
    if(not (data and data.MinisaacType and forcedCellBodyColors[data.MinisaacType])) then return end

    local sp = fam:GetSprite()
    data.SkinColor = forcedCellBodyColors[data.MinisaacType]
    sp:GetLayer(2):SetColor(data.SkinColor)
    sp:GetLayer(3):SetColor(data.SkinColor)
end
mod:AddPriorityCallback(ModCallbacks.MC_FAMILIAR_INIT, CallbackPriority.LATE, cellMinisaacInit, FamiliarVariant.MINISAAC)

---@param pl EntityPlayer
---@param trinket TrinketType
---@param firstTime boolean
local function addCellTrinket(_, pl, trinket, firstTime)
    if(not firstTime) then return end

    local rng = pl:GetTrinketRNG(trinket)
    local goldMult = (trinket & TrinketType.TRINKET_GOLDEN_FLAG ~= 0) and 2 or 1

    if(trinket==mod.TRINKET_ANIMAL_CELL) then
        spawnCellMinisaac(pl, rng, "ANIMAL", goldMult)
    elseif(trinket==mod.TRINKET_PLANT_CELL) then
        spawnCellMinisaac(pl, rng, "PLANT", goldMult)
    elseif(trinket==mod.TRINKET_FUNGI_CELL) then
        spawnCellMinisaac(pl, rng, "FUNGI", goldMult*FUNGICELL_NUM)
    elseif(trinket==mod.TRINKET_PROTIST_CELL) then
        spawnCellMinisaac(pl, rng, "PROTIST", goldMult)
    elseif(trinket==mod.TRINKET_PROKARYOTIC_CELL) then
        spawnCellMinisaac(pl, rng, "PROKARYOTIC", goldMult)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, addCellTrinket)

---@param pl EntityPlayer
local function respawnOnRoom(_, pl)
    local numCellMinisaacs = {
        ANIMAL = 0,
        PLANT = 0,
        FUNGI = 0,
        PROTIST = 0,
        PROKARYOTIC = 0,
    }

    local plHash = GetPtrHash(pl)

    for _, ent in ipairs(Isaac.FindByType(3,FamiliarVariant.MINISAAC)) do
        local fam = ent:ToFamiliar() ---@type EntityFamiliar
        if(GetPtrHash(fam.Player)==plHash) then
            local data = fam:GetData().DenisMinisaacData

            if(data and data.MinisaacType and numCellMinisaacs[data.MinisaacType]) then
                numCellMinisaacs[data.MinisaacType] = numCellMinisaacs[data.MinisaacType]+1
            end
        end
    end

    for key, num in pairs(numCellMinisaacs) do
        local trinketId = mod["TRINKET_"..key.."_CELL"]
        local rng = pl:GetTrinketRNG(trinketId)
        local desiredNum = pl:GetTrinketMultiplier(trinketId)
        if(key=="FUNGI") then desiredNum = desiredNum*FUNGICELL_NUM end

        spawnCellMinisaac(pl, rng, key, desiredNum-num)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, respawnOnRoom)

---@param tear EntityTear
local function cellTrinketLateTearInit(_, tear)
    if(tear.FrameCount~=0) then return end

    local spawner = tear.SpawnerEntity
    if(not (spawner and spawner.Type==3 and spawner.Variant==FamiliarVariant.MINISAAC)) then return end

    local data = spawner:GetData().DenisMinisaacData
    if(not data) then return end

    local rng = spawner:GetDropRNG()

    if(data.MinisaacType=="ANIMAL") then
        tear:ChangeVariant(TearVariant.BLOOD)
        tear.CollisionDamage = tear.CollisionDamage*ANIMALCELL_DMGMULT
    elseif(data.MinisaacType=="PLANT") then
        if(rng:RandomFloat()<PLANTCELL_POISON_CHANCE) then
            tear:AddTearFlags(TearFlags.TEAR_POISON)
            tear.Color = Color(0.8, 1.4, 0.7, 1, 0, 0.1, 0, 0.6, 1, 0.5, 1)
        end
    elseif(data.MinisaacType=="FUNGI") then
        tear.CollisionDamage = tear.CollisionDamage*FUNGICELL_DMGMULT
    elseif(data.MinisaacType=="PROTIST") then
        if(rng:RandomFloat()<PROTISTCELL_CONFUSE_CHANCE) then
            tear:AddTearFlags(TearFlags.TEAR_CONFUSION)
            tear.Color = Color(1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1)
        end
    elseif(data.MinisaacType=="PROKARYOTIC") then
        if(rng:RandomFloat()<PROKARYOTICCELL_WEAKNESS_CHANCE) then
            tear:GetData().DenisProkaryoticTear = true
            tear.Color = Color(1.3, 0.6, 1.3, 1, 0.1, 0, 0.1, 0.9, 0.4, 1, 1)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, cellTrinketLateTearInit)

---@param ent Entity
---@param source EntityRef
local function prokaryoticTearDamage(_, ent, _, _, source, _)
    local tear = source.Entity
    if(tear and tear:ToTear() and tear:GetData().DenisProkaryoticTear) then
        ent:AddWeakness(source, PROKARYOTICCELL_WEAKNESS_DUR)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, prokaryoticTearDamage)

---@param fam EntityFamiliar
local function animalMinisaacUpdate(_, fam)
    local data = fam:GetData().DenisMinisaacData
    if(not (data and data.MinisaacType=="ANIMAL")) then return end

    if(fam.FrameCount%ANIMALCELL_BLOOD_FREQ==0) then
        local bloodCreep = Isaac.Spawn(1000,EffectVariant.PLAYER_CREEP_RED,0,fam.Position,Vector.Zero,fam):ToEffect() ---@cast bloodCreep EntityEffect
        bloodCreep.Scale = 0.75
        bloodCreep.CollisionDamage = ANIMALCELL_BLOOD_DMG
        bloodCreep.Timeout = ANIMALCELL_BLOOD_TIMEOUT
        bloodCreep:Update()
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, animalMinisaacUpdate, FamiliarVariant.MINISAAC)

--#endregion

--#region EID

if(EID) then
    local descriptions = {
        AMOEBA = {
            "Consumes all item pedestals in the room and spawns a Minisaac for each one",
            "These Minisaacs are invincible and copy your tear effects"
        },
        MITOCHONDRIA = {
            "Using an active item spawns a Minisaac",
            "This Minisaac's damage scales with how many max charges the item has",
            "{{Battery}} On death, Minisaacs have a 25% chance to drop a Micro Battery",
        },
        CELLPHONE = {
            "{{Card50}} Use Emergency Contact 3 times",
        },
        POWERCELL = {
            "\1 x1.5 Damage",
            "When you have less than 3 total hearts:",
            "Get a {{BrokenHeart}} Broken Heart",
            "Lose all copies of this item",
        },
        CELLO = {
            "\2 x0.75 Tears",
            "{{Timer}} Every 6 seconds, x3 Tears for 2 seconds",
        },
        OCELLUS = {
            "Enemies are frozen while not in your line of sight",
        },

        ANIMAL_CELL = {
            "{{BleedingOut}} Grants a Minisaac that leaves a trail of blood creep and deals 1.5x damage",
            "Respawns on room entry",
        },
        PLANT_CELL = {
            "{{Poison}} Grants a Minisaac that may inflict Poison",
            "Respawns on room entry",
        },
        FUNGI_CELL = {
            "Grants 3 Minisaacs that deal 0.5x damage",
            "Respawns on room entry",
        },
        PROTIST_CELL = {
            "{{Confusion}} Grants a Minisaac that may inflict Confusion",
            "Respawns on room entry",
        },
        PROKARYOTIC_CELL = {
            "{{Weakness}} Grants a Minisaac that may inflict Weakness",
            "Respawns on room entry",
        },

        DENIS = {
            "Cannot shoot tears",
            "Instead charge up to throw a Minisaac, max amount of Minisaacs scales with Tears",
            "Minisaacs copy your tears and may copy tear replacements",
            "Some Minisaacs are guaranteed to always fire tear effects",
            "Can pickup and throw Minisaacs",
        },
        BIRTHRIGHT = {
            "{{Luck}} Minisaacs have +5 Luck",
        }
    }

    local formattedDescriptions = {}
    for key, val in pairs(descriptions) do
        local formattedString = ""
        for i, str in ipairs(val) do
            if(i~=1) then
                formattedString = formattedString.."#"
            end

            formattedString = formattedString..str
        end

        formattedDescriptions[key] = formattedString
    end

    EID:addCollectible(mod.COLLECTIBLE_AMOEBA, formattedDescriptions.AMOEBA, "Amoeba")
    EID:addCollectible(mod.COLLECTIBLE_MITOCHONDRIA, formattedDescriptions.MITOCHONDRIA, "Mitochondria")
    EID:addCollectible(mod.COLLECTIBLE_CELLPHONE, formattedDescriptions.CELLPHONE, "{{ColorTeal}}Cell{{ColorObjName}}phone")
    EID:addCollectible(mod.COLLECTIBLE_POWER_CELL, formattedDescriptions.POWERCELL, "Power {{ColorTeal}}Cell{{ColorObjName}}")
    EID:addCollectible(mod.COLLECTIBLE_CELLO, formattedDescriptions.CELLO, "{{ColorTeal}}Cell{{ColorObjName}}o")
    EID:addCollectible(mod.COLLECTIBLE_OCELLUS, formattedDescriptions.OCELLUS, "O{{ColorTeal}}cell{{ColorObjName}}us")

    EID:addTrinket(mod.TRINKET_ANIMAL_CELL, formattedDescriptions.ANIMAL_CELL, "Animal {{ColorTeal}}Cell{{ColorObjName}}")
    EID:addTrinket(mod.TRINKET_PLANT_CELL, formattedDescriptions.PLANT_CELL, "Plant {{ColorTeal}}Cell{{ColorObjName}}")
    EID:addTrinket(mod.TRINKET_FUNGI_CELL, formattedDescriptions.FUNGI_CELL, "Fungi {{ColorTeal}}Cell{{ColorObjName}}")
    EID:addTrinket(mod.TRINKET_PROTIST_CELL, formattedDescriptions.PROTIST_CELL, "Protist {{ColorTeal}}Cell{{ColorObjName}}")
    EID:addTrinket(mod.TRINKET_PROKARYOTIC_CELL, formattedDescriptions.PROKARYOTIC_CELL, "Prokaryotic {{ColorTeal}}Cell{{ColorObjName}}")

    EID.descriptions["en_us"].CharacterInfo[mod.PLAYER_DENIS] = {"Denis", formattedDescriptions.DENIS}
    EID:addBirthright(mod.PLAYER_DENIS, formattedDescriptions.BIRTHRIGHT)
end

--#endregion

--#region ACCURATE BLURBS

if(AccurateBlurbs) then
    local blurbItems = {
        [mod.COLLECTIBLE_AMOEBA] = "Absorb items to create special Minisaacs",
        [mod.COLLECTIBLE_CELLO] = "Tears down + occasional temp. tears up",
        [mod.COLLECTIBLE_CELLPHONE] = "Call many Mom’s Hands to grab enemies",
        [mod.COLLECTIBLE_MITOCHONDRIA] = "Spawn a scaling Minisaac on active use",
        [mod.COLLECTIBLE_OCELLUS] = "Petrify enemies behind",
        [mod.COLLECTIBLE_POWER_CELL] = "DMG up + (break + heartbreak) at low hp",
    }
    local blurbTrinkets = {
        [mod.TRINKET_ANIMAL_CELL] = "Spawn a bloody Minisaac",
        [mod.TRINKET_PLANT_CELL] = "Spawn a poisoning Minisaac",
        [mod.TRINKET_FUNGI_CELL] = "Spawn some Minisaacs",
        [mod.TRINKET_PROTIST_CELL] = "Spawn a confusing Minisaac",
        [mod.TRINKET_PROKARYOTIC_CELL] = "Spawn a weakening Minisaac",
    }

    local conf = Isaac.GetItemConfig()
    for item, desc in pairs(blurbItems) do
        conf:GetCollectible(item).Description = desc
    end

    for item, desc in pairs(blurbTrinkets) do
        conf:GetTrinket(item).Description = desc
    end
end

--#endregion

--#region SAVE DATA

local json = require("json")
mod.IS_DATA_LOADED = false

local function saveModData()
    local save = {}

    save.savedSeeds = SAVED_SEEDS

	mod:SaveData(json.encode(save))
end

function mod:saveNewFloor()
    if(mod.IS_DATA_LOADED) then
        saveModData()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.saveNewFloor)
function mod:saveGameExit(save)
    saveModData()
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveGameExit)

local function blablabla(_, slot)
    mod.IS_DATA_LOADED = false
end
mod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, blablabla)

local function initSaveData(_, player)
    mod.IS_DATA_LOADED = false

    if(#Isaac.FindByType(1)==0) then
        SAVED_SEEDS = {}
        if(Game():GetFrameCount()~=0 and mod:HasData()) then
            local save = json.decode(mod:LoadData())

            SAVED_SEEDS = save.savedSeeds or {}

            for key, val in pairs(SAVED_SEEDS) do
                print(key, val)
            end
        end
    end

    mod.IS_DATA_LOADED = true
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, -math.huge, initSaveData)

--#endregion

--#region CHARGEBAR CUSTOM

--Constants
local DISAPPEAR_ANIM = "Disappear"
local CHARGING_ANIM = "Charging"
local CHARGED_ANIM = "Charged"

local RENDER_NUM_TO_OFFSET = Vector(12, 0)

--Variables
local registeredChargebars = {}
local renderedChargebarNum = {}

--Function (helper)
local function getChargebarSprite(playerPtr, gfx)
    if not registeredChargebars[playerPtr] then
        registeredChargebars[playerPtr] = {}
    end

    if not registeredChargebars[playerPtr][gfx] then
        local sprite = Sprite()
        sprite:Load(gfx, true)
        sprite:Play(DISAPPEAR_ANIM, true)
        sprite:SetLastFrame()
        registeredChargebars[playerPtr][gfx] = sprite
    end

    return registeredChargebars[playerPtr][gfx]
end

local function updateAndEnforceChargebarAnim(sprite, animation)
    sprite:Update()
    if sprite:GetAnimation() ~= animation then
        sprite:Play(animation, true)
    end
end

local function updateChargebarSpriteAnim(chargebarSprite, completionPercent, shouldDisappear)
    if shouldDisappear then
        updateAndEnforceChargebarAnim(chargebarSprite, DISAPPEAR_ANIM)
    elseif completionPercent > 1.13 then
        updateAndEnforceChargebarAnim(chargebarSprite, CHARGED_ANIM)
    else
        chargebarSprite:SetFrame(CHARGING_ANIM, math.floor(completionPercent * 100))
    end
end

local function getChargebarRenderPos(player, playerPtr)
    local screenPosition = Isaac.WorldToScreen(player.Position)

    if Game():GetRoom():IsMirrorWorld() then
        screenPosition = Vector(-screenPosition.X, screenPosition.Y)
    end

    return screenPosition + renderedChargebarNum[playerPtr] * RENDER_NUM_TO_OFFSET
end

local function shouldRenderChargebar(sprite)
    return sprite:GetAnimation() ~= DISAPPEAR_ANIM or not sprite:IsFinished()
end

--Function (callback)
local function chargebarPostRender()
    renderedChargebarNum = {}
end

--Function (core)
function mod:renderCustomChargebar(player, gfx, offset, completionPercent, shouldDisappear)
    local playerPtr = GetPtrHash(player)
    local chargebarSprite = getChargebarSprite(playerPtr, gfx)

    if not renderedChargebarNum[playerPtr] then
        renderedChargebarNum[playerPtr] = 0
    end

    updateChargebarSpriteAnim(chargebarSprite, completionPercent, shouldDisappear)

    if not shouldRenderChargebar(chargebarSprite) then return end

    chargebarSprite:Render(getChargebarRenderPos(player, playerPtr) + offset)
    renderedChargebarNum[playerPtr] = renderedChargebarNum[playerPtr] + 1
end

--Init
mod:AddCallback(ModCallbacks.MC_POST_RENDER, chargebarPostRender)

--#endregion

--#region COOL PORTRAIT

local minisaacSprite = Sprite("gfx/ui/player_portraits/denis_minisaac_portrait.anm2", true)
minisaacSprite:SetFrame("Idle", 0)

local MINISAACS_TO_RENDER = {}
local WAS_RENDERING_INTRO = false

local function populateMinisaacTable()
    MINISAACS_TO_RENDER = {}

    local plHash = GetPtrHash(Isaac.GetPlayer())
    for _, fam in ipairs(Isaac.FindByType(3,FamiliarVariant.MINISAAC)) do
        local data = fam:GetData().DenisMinisaacData
        if(GetPtrHash(fam:ToFamiliar().Player)==plHash and data) then
            table.insert(MINISAACS_TO_RENDER, {
                SkinColor = data.SkinColor,
                CostumeColor = data.CostumeColor,
                CostumeID = data.CostumeID,
            })
        end
    end
end

---@param playerPos Vector
---@param frameRef AnimationFrame?
local function renderMinisaacTable(playerPos, frameRef)
    if(not frameRef) then return end
    if(not frameRef:IsVisible()) then return end
    if(#MINISAACS_TO_RENDER==0) then return end
    local renderPos = playerPos+Vector(-4,7)

    local numToRender = #MINISAACS_TO_RENDER
    local angleArc = (math.min(numToRender, 7)-1)/2*20
    if(numToRender==2) then
        angleArc = 20
    end

    local renderRadius = Vector(100,30)

    minisaacSprite.Color = frameRef:GetColor()
    minisaacSprite.Scale = frameRef:GetScale()

    for i=1, (numToRender+1)/2 do
        for j=0, (i~=numToRender+1-i and 1 or 0) do
            local trueIdx = j*(numToRender+1)+(1-j*2)*i
            local pos = Vector.FromAngle(90-(trueIdx-1/2)/numToRender*(2*angleArc)+angleArc)*renderRadius*minisaacSprite.Scale

            local data = MINISAACS_TO_RENDER[trueIdx]
            minisaacSprite:GetLayer(0):SetColor(data.SkinColor)
            minisaacSprite:GetLayer(2):SetColor(data.CostumeColor)
            minisaacSprite:SetLayerFrame(2, data.CostumeID)
            minisaacSprite:Render(renderPos+pos)
        end
    end
end

local function showNightmare(_)
    if(Isaac.GetPlayer():GetPlayerType()~=mod.PLAYER_DENIS) then return end
    populateMinisaacTable()
end
mod:AddCallback(ModCallbacks.MC_POST_NIGHTMARE_SCENE_SHOW, showNightmare)

local function renderNightmare(_)
    if(Isaac.GetPlayer():GetPlayerType()~=mod.PLAYER_DENIS) then return end

    local nightmareSp = NightmareScene:GetBackgroundSprite()
    local playerLayerId = nightmareSp:GetLayer("Player"):GetLayerID()
    local nFrame = nightmareSp:GetFrame()

    local animData = nightmareSp:GetCurrentAnimationData()
    local curFrame = animData:GetLayer(playerLayerId):GetFrame(nFrame)

    local screenCenter = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())/2
    renderMinisaacTable(curFrame:GetPos()+curFrame:GetPivot()+Vector(-72,0)+screenCenter, curFrame)
end
mod:AddCallback(ModCallbacks.MC_POST_NIGHTMARE_SCENE_RENDER, renderNightmare)

local function roomTransitionUpdate(_)
    local roomT = RoomTransition
    local isIntro = roomT:IsRenderingBossIntro()

    if(isIntro) then
        if(not WAS_RENDERING_INTRO) then
            populateMinisaacTable()
        end

        local bossSp = roomT:GetVersusScreenSprite()
        local playerLayerId = bossSp:GetLayer("PlayerPortrait"):GetLayerID()
        local bFrame = bossSp:GetFrame()

        local animData = bossSp:GetCurrentAnimationData()
        if(animData) then
            local curFrame = animData:GetLayer(playerLayerId):GetFrame(bFrame)
            local screenCenter = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())/2
            renderMinisaacTable(curFrame:GetPos()+screenCenter+Vector(0,-30), curFrame)
        end
    end

    WAS_RENDERING_INTRO = isIntro
end
mod:AddCallback(ModCallbacks.MC_POST_ROOM_TRANSITION_RENDER, roomTransitionUpdate)

--#endregion