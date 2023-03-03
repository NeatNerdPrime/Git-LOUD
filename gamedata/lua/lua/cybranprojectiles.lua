---  /data/lua/cybranprojectiles.lua

local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile
local OnWaterEntryEmitterProjectile = import('/lua/sim/defaultprojectiles.lua').OnWaterEntryEmitterProjectile
local SingleBeamProjectile = import('/lua/sim/defaultprojectiles.lua').SingleBeamProjectile
local MultiBeamProjectile = import('/lua/sim/defaultprojectiles.lua').MultiBeamProjectile
local SinglePolyTrailProjectile = import('/lua/sim/defaultprojectiles.lua').SinglePolyTrailProjectile
local MultiPolyTrailProjectile = import('/lua/sim/defaultprojectiles.lua').MultiPolyTrailProjectile 
local SingleCompositeEmitterProjectile = import('/lua/sim/defaultprojectiles.lua').SingleCompositeEmitterProjectile

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local DepthCharge = import('/lua/defaultantiprojectile.lua').DepthCharge

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateDecal = CreateDecal
local CreateTrail = CreateTrail

local CreateLightParticle = CreateLightParticle
local CreateEmitterAtEntity = CreateEmitterAtEntity
local CreateEmitterAtBone = CreateEmitterAtBone

local DamageArea = DamageArea
local ForkThread = ForkThread

local Random = Random
local SetCollisionShape = moho.entity_methods.SetCollisionShape

local LOUDSIN = math.sin
local LOUDCOS = math.cos

local WaitTicks = coroutine.yield

CIFProtonBombProjectile = Class(NullShell) {

    FxImpactUnit = EffectTemplate.CProtonBombHit01,
    FxImpactProp = EffectTemplate.CProtonBombHit01,
    FxImpactLand = EffectTemplate.CProtonBombHit01,

    OnImpact = function(self, targetType, targetEntity)
    
        local army = self.Army
		
        CreateLightParticle( self, -1, army, 12, 28, 'glow_03', 'ramp_proton_flash_02' )
        CreateLightParticle( self, -1, army, 8, 22, 'glow_03', 'ramp_antimatter_02' )
        
        if targetType == 'Terrain' or targetType == 'Prop' then
        
            local pos = self:GetPosition()
            
            DamageArea( self, pos, self.DamageData.DamageRadius * 0.25, 1, 'Force', true )
            DamageArea( self, pos, self.DamageData.DamageRadius * 0.25, 1, 'Force', true )          
            
            self.DamageData.DamageAmount = self.DamageData.DamageAmount - 10
            
            DamageRing( self, pos, 0.1, self.DamageData.DamageRadius, 10, 'Fire', false, false) 
            
            CreateDecal( pos, (Random() * 6.28), 'scorch_011_albedo', '', 'Albedo', 12, 12, 150, 200, army )            
        end

        local blanketSides = 12
        local blanketAngle =  6.28 / blanketSides
        local blanketStrength = 1
        local blanketVelocity = 6.25

        for i = 0, (blanketSides-1) do
        
            local blanketX = LOUDSIN(i*blanketAngle)
            local blanketZ = LOUDCOS(i*blanketAngle)
            
            self:CreateProjectile('/effects/entities/EffectProtonAmbient01/EffectProtonAmbient01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end

        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

CDFProtonCannonProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = { EffectTemplate.CProtonCannonPolyTrail,
        '/effects/emitters/default_polytrail_01_emit.bp',
    },

    FxTrails = EffectTemplate.CProtonCannonFXTrail01,
    FxImpactUnit = EffectTemplate.CProtonCannonHit01,
    FxImpactProp = EffectTemplate.CProtonCannonHit01,
    FxImpactLand = EffectTemplate.CProtonCannonHit01,
}

-- XRL0403 experimental crab heavy proton cannon
CDFHvyProtonCannonProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = { EffectTemplate.CHvyProtonCannonPolyTrail,
        '/effects/emitters/default_polytrail_01_emit.bp',
    },

    FxTrails = EffectTemplate.CHvyProtonCannonFXTrail01,
    FxImpactUnit = EffectTemplate.CHvyProtonCannonHitUnit,
    FxImpactProp = EffectTemplate.CHvyProtonCannonHitUnit,
    FxImpactLand = EffectTemplate.CHvyProtonCannonHitLand,
    FxImpactUnderWater = EffectTemplate.CHvyProtonCannonHit01,
    FxImpactWater = EffectTemplate.CHvyProtonCannonHit01,
}

CAADissidentProjectile = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/electron_bolter_trail_01_emit.bp',
    FxTrails = {'/effects/emitters/electron_bolter_munition_01_emit.bp',},

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProjectile = EffectTemplate.TMissileHit01,
}

CAAElectronBurstCloudProjectile = Class(SinglePolyTrailProjectile) {

	PolyTrail = '/effects/emitters/default_polytrail_02_emit.bp',

    FxImpactAirUnit = EffectTemplate.CElectronBurstCloud01,
    FxImpactNone = EffectTemplate.CElectronBurstCloud01,
}

CAAMissileNaniteProjectile = Class(SingleCompositeEmitterProjectile) {

    FxTrailOffset = -0.05,
    PolyTrail =  EffectTemplate.CNanoDartPolyTrail01,
    BeamName = '/effects/emitters/missile_nanite_exhaust_beam_01_emit.bp',

    FxUnitHitScale = 0.5,
    FxImpactAirUnit = EffectTemplate.CNanoDartUnitHit01,
    FxImpactNone = EffectTemplate.CNanoDartUnitHit01,
    FxImpactUnit = EffectTemplate.CNanoDartUnitHit01,
    FxImpactProp = EffectTemplate.CNanoDartUnitHit01,
    FxLandHitScale = 0.5,
    FxImpactLand = EffectTemplate.CMissileHit01,
}

CAAMissileNaniteProjectile03 = Class(CAAMissileNaniteProjectile) {}

CAANanoDartProjectile = Class(SinglePolyTrailProjectile) {

    PolyTrail= EffectTemplate.CNanoDartPolyTrail01,

    FxImpactAirUnit = EffectTemplate.CNanoDartUnitHit01,
    FxImpactUnit = EffectTemplate.CNanoDartUnitHit01,
    FxImpactLand = EffectTemplate.CNanoDartLandHit01,
}

CAANanoDartProjectile02 = Class(CAANanoDartProjectile) {

    PolyTrail= EffectTemplate.CNanoDartPolyTrail02,
}

-- adjustment to cheapen effects for URL0104
CAANanoDartProjectile03 = Class(CAANanoDartProjectile) {

    FxImpactAirUnit = EffectTemplate.CNanoDartUnitHit02,
    FxImpactUnit = EffectTemplate.CNanoDartUnitHit02,
    FxImpactLand = EffectTemplate.CNanoDartLandHit02,
}

CArtilleryProjectile = Class(EmitterProjectile) {

    FxTrails = {'/effects/emitters/mortar_munition_03_emit.bp',},

    FxImpactUnit = EffectTemplate.CNanoDartUnitHit01,
    FxImpactProp = EffectTemplate.CArtilleryHit01,
    FxImpactLand = EffectTemplate.CArtilleryHit01,
}

CArtilleryProtonProjectile = Class(SinglePolyTrailProjectile) {

	PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',

    FxImpactUnit = EffectTemplate.CProtonArtilleryHit01,
    FxImpactProp = EffectTemplate.CProtonArtilleryHit01,    
    FxImpactLand = EffectTemplate.CProtonArtilleryHit01,
}

CBeamProjectile = Class(NullShell) {

    FxUnitHitScale = 0.5,
    FxImpactUnit = EffectTemplate.CBeamHitUnit01,
    FxImpactProp = EffectTemplate.CBeamHitUnit01,
    FxImpactLand = EffectTemplate.CBeamHitLand01,
}

CBombProjectile = Class(EmitterProjectile) {

    FxTrails = {'/effects/emitters/bomb_munition_plasma_aeon_01_emit.bp'},

    FxImpactUnit = EffectTemplate.CBombHit01,
    FxImpactProp = EffectTemplate.CBombHit01,
    FxImpactLand = EffectTemplate.CBombHit01,
}

CCannonSeaProjectile = Class(SingleBeamProjectile) { BeamName = '/effects/emitters/cannon_munition_ship_cybran_beam_01_emit.bp' }

CCannonTankProjectile = Class(SingleBeamProjectile) { BeamName = '/effects/emitters/cannon_munition_ship_cybran_beam_01_emit.bp' }

CDFTrackerProjectile = Class(SingleCompositeEmitterProjectile) {

    FxInitial = {},
    TrailDelay = 1,
    FxTrails = {'/effects/emitters/missile_sam_munition_trail_01_emit.bp',},
    FxTrailOffset = 0.5,

    BeamName = '/effects/emitters/missile_sam_munition_exhaust_beam_01_emit.bp',

    FxUnitHitScale = 0.5,
    FxLandHitScale = 0.5,
    FxImpactLand = EffectTemplate.CMissileHit01,
}

CDisintegratorLaserProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
		'/effects/emitters/disintegrator_polytrail_04_emit.bp',
		'/effects/emitters/disintegrator_polytrail_05_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},
	FxTrails = EffectTemplate.CDisintegratorFxTrails01,  
	
    FxImpactUnit = EffectTemplate.CDisintegratorHitUnit01,
    FxImpactAirUnit = EffectTemplate.CDisintegratorHitAirUnit01,
    FxImpactProp = EffectTemplate.CDisintegratorHitUnit01,
    FxImpactLand = EffectTemplate.CDisintegratorHitLand01,
}

--	adjusments for URA0104 to tone down effect
CDisintegratorLaserProjectile02 = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
		'/effects/emitters/disintegrator_polytrail_04_emit.bp',
		'/effects/emitters/disintegrator_polytrail_05_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},
	
    FxImpactUnit = EffectTemplate.CDisintegratorHitUnit01,
    FxImpactAirUnit = EffectTemplate.CDisintegratorHitAirUnit01,
    FxImpactProp = EffectTemplate.CDisintegratorHitUnit01,
    FxImpactLand = EffectTemplate.CDisintegratorHitLand01,
}

CElectronBolterProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
		'/effects/emitters/electron_bolter_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_01_emit.bp',
	},

    FxTrails = {'/effects/emitters/electron_bolter_munition_01_emit.bp',},

    FxImpactUnit = EffectTemplate.CElectronBolterHitUnit01,
    FxImpactProp = EffectTemplate.CElectronBolterHitUnit01,
    FxImpactLand = EffectTemplate.CElectronBolterHitLand01,
}

CHeavyElectronBolterProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
		'/effects/emitters/electron_bolter_trail_01_emit.bp',
		'/effects/emitters/default_polytrail_05_emit.bp',
	},

    FxTrails = {'/effects/emitters/electron_bolter_munition_02_emit.bp',},

    FxImpactUnit = EffectTemplate.CElectronBolterHitUnit02,
    FxImpactProp = EffectTemplate.CElectronBolterHitUnit02,
    FxImpactLand = EffectTemplate.CElectronBolterHitLand02,
    
    FxAirUnitHitScale = 2.5,
    FxLandHitScale = 2.5,
    FxNoneHitScale = 2.5,
    FxPropHitScale = 2.5,
    FxProjectileHitScale = 2.5,
    FxShieldHitScale = 2.5,
    FxUnitHitScale = 2.5,
    FxWaterHitScale = 2.5,
    FxOnKilledScale = 2.5, 
}

CEMPFluxWarheadProjectile = Class(SingleBeamProjectile) {

    BeamName = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp',
    FxInitialAtEntityEmitter = {},
    FxUnderWaterTrail = {'/effects/emitters/missile_cruise_munition_underwater_trail_01_emit.bp',},
    FxOnEntityEmitter = {},
    FxExitWaterEmitter = EffectTemplate.DefaultProjectileWaterImpact,
    FxSplashScale = 0.65,
    ExitWaterTicks = 9,
    FxTrailOffset = -0.5,

    FxLaunchTrails = {},

    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},
}

CFlameThrowerProjectile = Class(EmitterProjectile) {

    FxTrails = {'/effects/emitters/flamethrower_02_emit.bp'},
    FxTrailScale = 1,
}

CIFMolecularResonanceShell = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',

    FxImpactUnit = EffectTemplate.CMolecularResonanceHitUnit01,
    FxImpactProp = EffectTemplate.CMolecularResonanceHitUnit01,
    FxImpactLand = EffectTemplate.CMolecularResonanceHitUnit01,

    OnCreate = function(self)
        SinglePolyTrailProjectile.OnCreate(self)
        self.Impacted = false
    end,

    DelayedDestroyThread = function(self)
        WaitTicks( 3 )
        self.CreateImpactEffects( self, self.Army, self.FxImpactUnit, self.FxUnitHitScale )
        self:Destroy()
    end,

    OnImpact = function(self, TargetType, TargetEntity)
        if self.Impacted == false then
            self.Impacted = true
            if TargetType == 'Terrain' then
                SinglePolyTrailProjectile.OnImpact(self, TargetType, TargetEntity)
                self:ForkThread( self.DelayedDestroyThread )
            else
                SinglePolyTrailProjectile.OnImpact(self, TargetType, TargetEntity)
                self:Destroy()
            end
        end
    end,
}

CIridiumRocketProjectile = Class(SingleCompositeEmitterProjectile) {

	PolyTrail = '/effects/emitters/cybran_iridium_missile_polytrail_01_emit.bp',    
    BeamName = '/effects/emitters/rocket_iridium_exhaust_beam_01_emit.bp',
    FxImpactUnit = EffectTemplate.CMissileHit02,
    FxImpactProp = EffectTemplate.CMissileHit02,
    FxImpactLand = EffectTemplate.CMissileHit02,
}

CCorsairRocketProjectile = Class(SingleCompositeEmitterProjectile) {

	PolyTrail = EffectTemplate.CCorsairMissilePolyTrail01,    
    BeamName = '/effects/emitters/rocket_iridium_exhaust_beam_01_emit.bp',
    FxImpactUnit = EffectTemplate.CCorsairMissileUnitHit01,
    FxImpactProp = EffectTemplate.CCorsairMissileHit01,
    FxImpactLand = EffectTemplate.CCorsairMissileLandHit01,
}

CLaserLaserProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
        '/effects/emitters/cybran_laser_trail_01_emit.bp',
		'/effects/emitters/default_polytrail_02_emit.bp',
	},

    FxImpactUnit = EffectTemplate.CLaserHitUnit01,
    FxImpactProp = EffectTemplate.CLaserHitUnit01,
    FxImpactLand = EffectTemplate.CLaserHitLand01,
}

CHeavyLaserProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
        '/effects/emitters/cybran_laser_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},
	
    FxImpactUnit = EffectTemplate.CLaserHitUnit01,
    FxImpactProp = EffectTemplate.CLaserHitUnit01,
    FxImpactLand = EffectTemplate.CLaserHitLand01,
}

CMolecularCannonProjectile = Class(SinglePolyTrailProjectile) {

    FxImpactTrajectoryAligned = false,
    PolyTrail = '/effects/emitters/default_polytrail_03_emit.bp',
    FxTrails = EffectTemplate.CMolecularCannon01,

    FxImpactUnit = EffectTemplate.CMolecularRipperHit01,
    FxImpactProp = EffectTemplate.CMolecularRipperHit01,
    FxImpactLand = EffectTemplate.CMolecularRipperHit01,
}

CMissileAAProjectile = Class(SingleCompositeEmitterProjectile) {

    FxInitial = {},
    TrailDelay = 1,
    FxTrails = {'/effects/emitters/missile_sam_munition_trail_01_emit.bp',},
    FxTrailOffset = 0.5,

    BeamName = '/effects/emitters/missile_sam_munition_exhaust_beam_01_emit.bp',

    FxUnitHitScale = 0.5,
    FxImpactUnit = EffectTemplate.CMissileHit01,
    FxImpactProp = EffectTemplate.CMissileHit01,    
    FxLandHitScale = 0.5,
    FxImpactLand = EffectTemplate.CMissileHit01,

    OnCreate = function(self)
    
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0)
        
        SingleBeamProjectile.OnCreate(self)
    end,
}

CNeutronClusterBombChildProjectile = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/default_polytrail_05_emit.bp',

    FxImpactUnit = EffectTemplate.CNeutronClusterBombHitUnit01,
    FxImpactProp = EffectTemplate.CNeutronClusterBombHitUnit01,    
    FxImpactLand = EffectTemplate.CNeutronClusterBombHitLand01,
    FxImpactWater = EffectTemplate.CNeutronClusterBombHitWater01,

    DoDamage = function(self, instigator, damageData, targetEntity)
    end,
}

CNeutronClusterBombProjectile = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/default_polytrail_03_emit.bp',

    ChildProjectile = '/projectiles/CIFNeutronClusterBomb02/CIFNeutronClusterBomb02_proj.bp',

    OnCreate = function(self)
        SinglePolyTrailProjectile.OnCreate(self)
        self.Impacted = false
    end,

    -- Over-ride the way damage is dealt to allow custom damage to be dealt.
    -- Spec 9/21/05 states that possible instakill functionality could be dealt
    -- to unit, dependent on units current armor level.
    DoDamage = function(self, instigator, damageData, targetEntity)
        SinglePolyTrailProjectile.DoDamage(self, instigator, damageData, targetEntity)
    end,

    -- Note: Damage is done once in AOE by main projectile. Secondary projectiles are just visual.
    OnImpact = function(self, TargetType, TargetEntity)
        if self.Impacted == false and TargetType != 'Air' then
		
			local Random = Random
			
            self.Impacted = true
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(0,Random(1,3),Random(1.5,3))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(Random(1,2),Random(1,3),Random(1,2))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(0,Random(1,3),-Random(1.5,3))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(Random(1.5,3),Random(1,3),0)
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1,2),Random(1,3),-Random(1,2))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1.5,2.5),Random(1,3),0)
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1,2),Random(1,3),Random(2,4))
            SinglePolyTrailProjectile.OnImpact(self, TargetType, TargetEntity)
        end
    end,
    
    OnImpactDestroy = function( self, TargetType, TargetEntity)
        self:ForkThread( self.DelayedDestroyThread )
    end,

    DelayedDestroyThread = function(self)
        WaitTicks( 5 )
        self:Destroy()
    end,
}

CParticleCannonProjectile = Class(SingleBeamProjectile) {

    BeamName = '/effects/emitters/laserturret_munition_beam_01_emit.bp',

    FxImpactUnit = EffectTemplate.CParticleCannonHitUnit01,
    FxImpactProp = EffectTemplate.CParticleCannonHitUnit01,
    FxImpactLand = EffectTemplate.CParticleCannonHitLand01,
}

CRailGunProjectile = Class(EmitterProjectile) {

    FxTrails = {'/effects/emitters/railgun_munition_trail_02_emit.bp',
                '/effects/emitters/railgun_munition_trail_01_emit.bp'},
    FxTrailScale = 0,
}

CRocketProjectile = Class(SingleBeamProjectile) {

    BeamName = '/effects/emitters/rocket_iridium_exhaust_beam_01_emit.bp',

    FxImpactUnit = EffectTemplate.CMissileHit01,
    FxImpactProp = EffectTemplate.CMissileHit01,
    FxImpactLand = EffectTemplate.CMissileHit01,
}

CLOATacticalMissileProjectile = Class(SingleBeamProjectile) {

    BeamName = '/effects/emitters/missile_loa_munition_exhaust_beam_01_emit.bp',
    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},
    FxTrailOffset = -0.5,
    FxExitWaterEmitter = EffectTemplate.TIFCruiseMissileLaunchExitWater,
    
    FxImpactUnit = EffectTemplate.CMissileLOAHit01,
    FxImpactLand = EffectTemplate.CMissileLOAHit01,
    FxImpactProp = EffectTemplate.CMissileLOAHit01,
    FxImpactNone = EffectTemplate.CMissileLOAHit01,

    OnExitWater = function(self)
    
		EmitterProjectile.OnExitWater(self)
		
		for k, v in self.FxExitWaterEmitter do
			CreateEmitterAtBone( self, -2, self.Army, v)
		end
    end,
}

CLOATacticalChildMissileProjectile = Class(SingleBeamProjectile) {

    BeamName = '/effects/emitters/missile_loa_munition_exhaust_beam_02_emit.bp',
    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_03_emit.bp',},
    FxTrailOffset = -0.5,
    FxExitWaterEmitter = EffectTemplate.TIFCruiseMissileLaunchExitWater,
    
    FxImpactUnit = EffectTemplate.CMissileLOAHit01,
    FxImpactLand = EffectTemplate.CMissileLOAHit01,
    FxImpactProp = EffectTemplate.CMissileLOAHit01,

    FxImpactNone = EffectTemplate.CMissileLOAHit01,
    FxAirUnitHitScale = 0.375,
    FxLandHitScale = 0.375,
    FxNoneHitScale = 0.375,
    FxPropHitScale = 0.375,
    FxProjectileHitScale = 0.375,
    FxShieldHitScale = 0.375,
    FxUnitHitScale = 0.375,
    FxWaterHitScale = 0.375,
    FxOnKilledScale = 0.375,       
    
    OnCreate = function(self)
    
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0)
        
        SingleBeamProjectile.OnCreate(self)
    end,
    
    OnImpact = function(self, targetType, targetEntity)

        CreateLightParticle( self, -1, self.Army, 1, 7, 'glow_03', 'ramp_fire_11' ) 
        
        SingleBeamProjectile.OnImpact(self, targetType, targetEntity)
    end,

    OnExitWater = function(self)
    
		EmitterProjectile.OnExitWater(self)

		for k, v in self.FxExitWaterEmitter do
			CreateEmitterAtBone( self, -2, self.Army, v )
		end
    end,
}

CShellAAAutoCannonProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
		'/effects/emitters/auto_cannon_trail_01_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},

    FxImpactUnit = {'/effects/emitters/auto_cannon_hit_flash_01_emit.bp', },
    FxImpactProp ={'/effects/emitters/auto_cannon_hit_flash_01_emit.bp', },
    FxImpactAirUnit = {'/effects/emitters/auto_cannon_hit_flash_01_emit.bp', },
}

CShellRiotProjectile = Class(SingleBeamProjectile) {

    BeamName = '/effects/emitters/riotgun_munition_beam_01_emit.bp',

    FxImpactUnit = {'/effects/emitters/destruction_explosion_sparks_01_emit.bp',},
    FxImpactProp = {'/effects/emitters/destruction_explosion_sparks_01_emit.bp',},
    FxLandHitScale = 3,
    FxImpactLand = {'/effects/emitters/destruction_land_hit_puff_01_emit.bp',},
}

CTorpedoShipProjectile = Class(OnWaterEntryEmitterProjectile) {

    FxSplashScale = 0.5,
    FxTrails = {'/effects/emitters/torpedo_munition_trail_01_emit.bp',},
    FxTrailScale = 1.25,
    FxTrailOffset = 0.2,    
    FxEnterWater= { '/effects/emitters/water_splash_ripples_ring_01_emit.bp','/effects/emitters/water_splash_plume_01_emit.bp'},

    FxUnitHitScale = 1.25,
    FxImpactUnit = EffectTemplate.CTorpedoUnitHit01,
    FxImpactProp = EffectTemplate.CTorpedoUnitHit01,
    FxImpactUnderWater = EffectTemplate.CTorpedoUnitHit01,

    OnCreate = function(self, inWater)
    
        OnWaterEntryEmitterProjectile.OnCreate(self, inWater)
        
        -- if we are starting in the water then immediately switch to tracking in water
        if inWater == true then
            self:TrackTarget(true):StayUnderwater(true)
            self:OnEnterWater(self)
        end
    end,
    
    OnEnterWater = function(self)
    
        OnWaterEntryEmitterProjectile.OnEnterWater(self)
        
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0)
    end,     
}

CTorpedoSubProjectile = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/torpedo_underwater_wake_02_emit.bp',},

    FxUnitHitScale = 1.25,
    FxImpactUnit = EffectTemplate.CTorpedoUnitHit01,
    FxImpactProp = EffectTemplate.CTorpedoUnitHit01,
    FxImpactUnderWater = EffectTemplate.CTorpedoUnitHit01,    
    FxImpactLand = EffectTemplate.CTorpedoUnitHit01,
    FxLandHitScale = 0.25,

    OnCreate = function(self, inWater)
    
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0)
        
        EmitterProjectile.OnCreate(self, inWater)
    end,
}

CDepthChargeProjectile = Class(OnWaterEntryEmitterProjectile) {

    FxInitial = {},
	
    FxTrails = {'/effects/emitters/anti_torpedo_flare_01_emit.bp','/effects/emitters/anti_torpedo_flare_02_emit.bp'},

    FxImpactUnit = EffectTemplate.CAntiTorpedoHit01,
    FxImpactProp = EffectTemplate.CAntiTorpedoHit01,
    FxImpactUnderWater = EffectTemplate.CAntiTorpedoHit01,    
    FxImpactProjectile = EffectTemplate.CAntiTorpedoHit01,
    FxImpactNone = EffectTemplate.CAntiTorpedoHit01,
    FxOnKilled = EffectTemplate.CAntiTorpedoHit01,
    FxEnterWater= EffectTemplate.WaterSplash01,

    OnCreate = function(self, inWater)
	
        OnWaterEntryEmitterProjectile.OnCreate(self)
     
        self:TrackTarget(false)
    end,

    OnEnterWater = function(self)
	
        OnWaterEntryEmitterProjectile.OnEnterWater(self)

        for k, v in self.FxEnterWater do
            CreateEmitterAtEntity( self, self.Army, v )
        end
        
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0)
        
        self:TrackTarget(false)
        self:StayUnderwater(true)
        self:SetTurnRate(0)
        self:SetMaxSpeed(1)
        self:SetVelocity(0, -0.25, 0)
        self:SetVelocity(0.25)
		
    end,

    AddDepthCharge = function(self, tbl)
	
        if not tbl then return end
		
        if not tbl.Radius then return end
		
        self.MyDepthCharge = DepthCharge { Owner = self, Radius = tbl.Radius or 10,}
		
		if not self.Trash then
		
			self.Trash = TrashBag()
			
		end
		
        self.Trash:Add(self.MyDepthCharge)
    end,
}

CHeavyDisintegratorPulseLaser = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
		'/effects/emitters/disintegrator_polytrail_02_emit.bp',
		'/effects/emitters/disintegrator_polytrail_03_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},

    FxImpactUnit = EffectTemplate.CHvyDisintegratorHitUnit01,
    FxImpactProp = EffectTemplate.CHvyDisintegratorHitUnit01,
    FxImpactLand = EffectTemplate.CHvyDisintegratorHitLand01,
}

CKrilTorpedo = Class(OnWaterEntryEmitterProjectile) {}

--[[
CDFBrackmanHackPegProjectile01 = Class(MultiPolyTrailProjectile) {

    PolyTrails = EffectTemplate.CBrackmanCrabPegPodTrails,
}

CDFBrackmanHackPegProjectile02 = Class(MultiPolyTrailProjectile) {

    PolyTrails = EffectTemplate.CBrackmanCrabPegTrails,

    FxImpactLand = EffectTemplate.CBrackmanCrabPegHit01,
}
--]]