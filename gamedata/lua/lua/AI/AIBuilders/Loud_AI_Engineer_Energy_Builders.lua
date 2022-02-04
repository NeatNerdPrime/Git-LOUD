-- Loud_AI_Engineer_Energy_Builders.lua

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'

-- imbedded into the Builder
local First30Minutes = function( self,aiBrain )
	
	if aiBrain.CycleTime > 1800 then
		return 0, false
	end
	
	return self.Priority,true
end

local First45Minutes = function( self,aiBrain )
	
	if aiBrain.CycleTime > 2700 then
		return 0, false
	end
	
	return self.Priority,true
end

local First60Minutes = function( self,aiBrain )
	
	if aiBrain.CycleTime > 3600 then
		return 0, false
	end
	
	return self.Priority,true
end


BuilderGroup {BuilderGroupName = 'Engineer Energy Builders',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'T1 Power Template',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        InstanceCount = 2,
		
        Priority = 761,
		
		PriorityFunction = First45Minutes,
		
        BuilderConditions = {
		
			{ EBC, 'LessThanEconEnergyStorageCurrent', { 6000 }},
			{ EBC, 'GreaterThanEconStorageCurrent', { 75, 0 }},
            
			{ UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION - categories.TECH1 }},                        
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION * categories.STRUCTURE * categories.TECH3 }},
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 35,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'PowerLayout',
				
                BuildStructures = {	'T1EnergyProduction' },
            }
        }
    },
	
    Builder {BuilderName = 'T2 Power Template',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 900,
        
		PriorityFunction = First60Minutes,
        
        BuilderConditions = {
        
			{ EBC, 'LessThanEnergyTrend', { 40 }},        
			{ EBC, 'LessThanEnergyTrendOverTime', { 50 }},
			{ EBC, 'LessThanEconEnergyStorageRatio', { 80 }},
            
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 - categories.HYDROCARBON }},
			{ UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION - categories.TECH1 }},            
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 6, categories.ENERGYPRODUCTION - categories.TECH1 }},
        },
		
        BuilderType = {'T2'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 6,
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 75,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'PowerLayout',
				
                BuildStructures = { 'T2EnergyProduction' },
            }
        }
    },

    Builder {BuilderName = 'T3 Power Template',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 900,

        BuilderConditions = {
        
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
			{ EBC, 'LessThanEnergyTrend', { 180 }},        
			{ EBC, 'LessThanEnergyTrendOverTime', { 240 }},
			{ EBC, 'LessThanEconEnergyStorageRatio', { 80 }},            

			{ UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION * categories.TECH3 }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 26, (categories.ENERGYPRODUCTION * categories.TECH3) - categories.HYDROCARBON }},
        },
		
		BuilderType = { 'T3','SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 7,
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 55,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'PowerLayout',
				
                BuildStructures = { 'T3EnergyProduction' },
            }
        }
    },
	
    Builder {BuilderName = 'Hydrocarbon',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 750,
        
        BuilderConditions = {
        
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .65 } },
			{ LUTL, 'HaveLessThanUnitsWithCategory', { 3, categories.HYDROCARBON * categories.STRUCTURE }},
			
            { EBC, 'CanBuildOnHydroLessThanDistance',  { 'LocationType', 350, -9999, 30, 0, 'AntiSurface', 1 }},
        },
		
        BuilderType = { 'T1','T2' },
		
        BuilderData = {
            Construction = {
                BuildStructures = {'T1HydroCarbon'},
                
				LoopBuild = true,
                
                MaxRange = 350,

				ThreatMax = 30,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',                
            }
        }
    },	
	
    -- This platoon comes into play at the end of the T3 power template
    -- usually only when the base gets very large
    Builder {BuilderName = 'T3 Power - Perimeter',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 900,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 50000 }},
            
			{ EBC, 'LessThanEnergyTrend', { 180 }},			
			{ EBC, 'LessThanEnergyTrendOverTime', { 240 }},
   			{ EBC, 'LessThanEconEnergyStorageRatio', { 70 }},
			
			-- must have much of the inner core power systems complete
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 20, (categories.ENERGYPRODUCTION * categories.TECH3) - categories.HYDROCARBON, 0, 59 }},
			-- must have less than 9 T3 power in the perimeter already
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 9, categories.ENERGYPRODUCTION * categories.TECH3, 60, 80 }},
			{ UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.ENERGYPRODUCTION * categories.TECH3 }},
        },
		
		BuilderType = { 'T3','SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 5,
            Construction = {
			
				Radius = 68,
                NearBasePerimeterPoints = true,
				
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = { 'T3EnergyProduction' },
            }
        }
    },
	
}

-- Energy Building is focused mainly at the MAIN position but 
-- additional energy will be built when unit count allows it
BuilderGroup {BuilderGroupName = 'Engineer Energy Builders - Expansions',
    BuildersType = 'EngineerBuilder',
   
    Builder {BuilderName = 'Hydrocarbon - Expansion',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 700,
        
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .65 } },
			
            { EBC, 'CanBuildOnHydroLessThanDistance',  { 'LocationType', 350, -9999, 30, 0, 'AntiSurface', 1 }},
        },
		
        BuilderType = { 'T2' },
		
        BuilderData = {
            Construction = {
                BuildStructures = { 'T1HydroCarbon' },
                
				LoopBuild = false,	#-- build only once then RTB
                
                MaxRange = 350,

				ThreatMax = 30,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',                
            }
        }
    },    
	
    Builder {BuilderName = 'T3 Power Template - Expansion',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 750,
		
        BuilderType = { 'T3','SubCommander' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
            
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 2, categories.FACTORY - categories.TECH1 }},

			{ EBC, 'LessThanEnergyTrend', { 180 }},			
			{ EBC, 'LessThanEnergyTrendOverTime', { 240 }},
   			{ EBC, 'LessThanEconEnergyStorageRatio', { 80 }},
            
			-- don't build T3 power if one is already being built somewhere else
			{ UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.ENERGYPRODUCTION * categories.TECH3 }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 16, (categories.ENERGYPRODUCTION * categories.TECH3) - categories.HYDROCARBON }},
        },
        
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 5,
            Construction = {
			
				Radius = 1,
				NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = { 'T3EnergyProduction' },
            }
        }
    },
}

-- As with expansions, Naval bases will build some additional power
-- provided we're well under unit cap
BuilderGroup {BuilderGroupName = 'Engineer Energy Builders - Naval',
    BuildersType = 'EngineerBuilder',

	-- this one is different than usual in that there is no check to see if building any other T3 power elsewhere
    Builder {BuilderName = 'T3 Power - Naval',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 800,
		
        BuilderType = { 'T3','SubCommander' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
            
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 2, categories.FACTORY - categories.TECH1 }},
			
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 8, (categories.ENERGYPRODUCTION * categories.TECH3) - categories.HYDROCARBON }},
            
			{ EBC, 'LessThanEnergyTrend', { 180 }},            
			{ EBC, 'LessThanEnergyTrendOverTime', { 240 }},
			{ EBC, 'LessThanEconEnergyStorageRatio', { 70 }},            
        },
        
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 5,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
			
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
                BuildStructures = { 'T3EnergyProduction' },
            }
        }
    },
}

-- this only comes into play when IS is turned on - rings local MEX with power
BuilderGroup {BuilderGroupName = 'Engineer Mass Energy Construction',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Mass Energy Adjacency',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
        
        PlatoonAIPlan = 'EngineerBuildMassAdjacencyAI',
		
        Priority = 750,
		
		PriorityFunction = First45Minutes,

		InstanceCount = 1,
		
        BuilderType = { 'T1' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ UCBC, 'MassExtractorInRangeHasLessThanEnergy', {'LocationType', 20, 180, 4 }},
        },
		
        BuilderData = {
            Construction = {
				LoopBuild = true,
				
				MinRadius = 20,
				Radius = 180,
				
				MinStructureUnits = 4,
                
                AdjacencyStructure = categories.ENERGYPRODUCTION * categories.TECH1,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'EnergyAdjacency',
				
                BuildStructures = {
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                }
            }
        }
    },
	
}

-- only used when IS is turned off
BuilderGroup {BuilderGroupName = 'Engineer Energy Storage Construction',
    BuildersType = 'EngineerBuilder',
	
	Builder {BuilderName = 'Energy Storage - HydroCarbon',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 700,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategory', { 0, categories.HYDROCARBON }},
            { UCBC, 'AdjacencyCheck', { 'LocationType', 'HYDROCARBON', 450, 'ueb1105' }},
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
            Construction = {
			
				AdjacencyCategory = categories.HYDROCARBON,
                AdjacencyDistance = 450,
                
                BuildStructures = {
                    'EnergyStorage',
					'EnergyStorage',
                },
            }
        }
    },
}


--[[
BuilderGroup {BuilderGroupName = 'Energy Facility',
    BuildersType = 'EngineerBuilder',
	
-- starts the production of T3 Power by building a sub-facility at the rear of the base
-- maps with starting positions too close to the edge of the map - or on rugged ground
-- will cause this to fail and 'upset' the entire applecart
    Builder {BuilderName = 'T3 Power Facility',
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 990,
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, (categories.ENERGYPRODUCTION * categories.TECH3) - categories.HYDROCARBON }},
        },
		
        BuilderType = { 'T3' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 5,
            Construction = {
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 1,
				Iterations = 1,
				Radius = 50,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'T3PowerFacility',
                BuildStructures = {
					'T3EnergyProduction',
					'T3EnergyProduction',
					'T3EnergyProduction',
					'T3EnergyProduction',
					'T2ShieldDefense',
					'T2ShieldDefense',
					'T3MassCreation',
					'T2MissileDefense',
					'T2MissileDefense',
					'T2AADefense',
					'T2AADefense',
					'T3AADefense',
					'T3AADefense',
					'T3AADefense',
					'T3AADefense',
					'T3GroundDefense',
					'T3GroundDefense',
                },
            }
        }
    },

    Builder {BuilderName = 'Energy Storage Power Facility',
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 750,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 8, categories.ENERGYSTORAGE }},
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION - categories.TECH1 }},
        },
		
        BuilderType = { 'T1','T2' },
		
        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 1,
				Iterations = 1,
				Radius = 50,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'T3PowerFacility',
                BuildStructures = {
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
                },
            }
        }
    },

    Builder {BuilderName = 'Energy Storage Power Facility Stage 2',
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 710,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 16, categories.ENERGYSTORAGE }},
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.ENERGYPRODUCTION - categories.TECH1 }},
        },
		
        BuilderType = { 'T1','T2' },
		
        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 1,
				Iterations = 1,
				Radius = 50,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'T3PowerFacility',
                BuildStructures = {
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
                },
            }
        }
    },
}	

BuilderGroup {BuilderGroupName = 'Energy Facility - LOUD_IS',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'T3 Power Facility - LOUD_IS',
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 990,
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, (categories.ENERGYPRODUCTION * categories.TECH3) - categories.HYDROCARBON }},
        },
		
        BuilderType = { 'T3' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 5,
            Construction = {
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 1,
				Iterations = 1,
				Radius = 50,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'T3PowerFacility',
                BuildStructures = {
					'T3EnergyProduction',
					'T3EnergyProduction',
					'T3EnergyProduction',
					'T3EnergyProduction',
					'T2ShieldDefense',
					'T2ShieldDefense',
					'T3MassCreation',
					'T2MissileDefense',
					'T2MissileDefense',
					'T2AADefense',
					'T2AADefense',
					'T3AADefense',
					'T3AADefense',
					'T3AADefense',
					'T3AADefense',
					'T3GroundDefense',
					'T3GroundDefense',
                },
            }
        }
    },
}

--]]
