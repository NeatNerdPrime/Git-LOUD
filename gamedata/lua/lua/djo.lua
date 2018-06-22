-- Library/Function to implement time based logging of army stats for plotting verus time
--
-- Current Feature Set: Mass and Energy Income Only
-- Future Feature Sets:
--
--  Engineering Power, Building Tech Level, Major Milestones (first T2,3 facs, T3 power, Omni, % mass extractors at each tech level
--  Size of Army, average tech level, area of control, engaged army capacity
--
-- To Implement place the following into aibrain.lua
-- Somewhere after "local import" statement on approx. line 34:
-- local djoFn = import('/lua/djo.lua').djoFn
-- In main "while true" loop (search for "for the entire session"):
-- djoFn(Brains)

local GetArmyStat = moho.aibrain_methods.GetArmyStat
local firstRunComplete = 0
local nextLogTime = 0.0
local logIncrement = 10.0 --5*60.0 -- in seconds (debuggins 10 seconds, real run value 5*60)
local GetListOfUnits = moho.aibrain_methods.GetListOfUnits

function djoFn(Brains)
	local outputStringLine = ""

	if(firstRunComplete == 0) then
		firstRunComplete = 1
		local numRecorded = 0
		local numBrains = table.getn(Brains)  -- change to table.getn
		LOG( 'DJO: DJO hooked in and ready to log data' )
		LOG( 'DJO: ' .. numBrains .. ' brains detected.')
		outputStringLine = outputStringLine .. "Time" .. ","

		for index, brain in Brains do
			if(not ArmyIsCivilian(ArmyBrains[index].ArmyIndex) ) then 
				numRecorded = numRecorded + 1
				local curNickname = brain.Nickname
				outputStringLine = outputStringLine .. curNickname .. "_" .. "EnergInc" .. ","
				outputStringLine = outputStringLine .. curNickname .. "_" .. "MassWast" .. ","
				outputStringLine = outputStringLine .. curNickname .. "_" .. "BldPower" .. ","
				outputStringLine = outputStringLine .. curNickname .. "_" .. "MassProd" .. ","
				outputStringLine = outputStringLine .. curNickname .. "_" .. "EnrgProd" .. ","
			end -- (civilian) if check
		end
		LOG( 'DJO: ' .. numRecorded .. ' brains being recorded.')

		LOG('DJO:' .. outputStringLine)
	end
	
	if( GetGameTimeSeconds() > nextLogTime ) then
		outputStringLine = ""
		nextLogTime = nextLogTime + logIncrement
		outputStringLine = outputStringLine .. dRound(GetGameTimeSeconds()) .. ","
		
		for index, brain in Brains do
			if(not ArmyIsCivilian(ArmyBrains[index].ArmyIndex) ) then 
			if(not ArmyIsOutOfGame(ArmyBrains[index].ArmyIndex)) then 
				-- **** Game generatored Mass/Energy Stats
				--outputStringLine = outputStringLine .. GetArmyStat( brain, "Economy_Income_Mass", 0.0).Value*10 .. ","
				outputStringLine = outputStringLine .. GetArmyStat( brain, "Economy_Income_Energy", 0.0).Value*10 .. ","
				outputStringLine = outputStringLine .. dRound(GetArmyStat( brain,"Economy_AccumExcess_Mass",0.0).Value) .. ","

				-- **** Build Power
				outputStringLine = outputStringLine .. djo_CalcBuildPower(brain) .. ","
				-- **** Improved Mass Algorithm
				outputStringLine = outputStringLine .. djo_CalcMassProd(brain) .. ","
				-- **** Improved Energy Algorithm
				outputStringLine = outputStringLine .. djo_CalcEnrgProd(brain) .. ","
				
			else  -- Brain is dead, return 0's for all stats
				outputStringLine = outputStringLine .. 0 .. ","
				outputStringLine = outputStringLine .. 0 .. ","
				outputStringLine = outputStringLine .. 0 .. ","
				outputStringLine = outputStringLine .. 0 .. ","
				outputStringLine = outputStringLine .. 0 .. ","
			end -- (out of game) if check
			end -- (civilian) if check
		end	-- Brains For Loop
		LOG('DJO:' .. outputStringLine)
		
	end -- Main time limiting if statement
	
end -- End djoFn

function djo_CalcEnrgProd(brain)
	local curCalcEnrgProd = 0
	
	local brnComs = brain:GetListOfUnits(categories.COMMAND, false)  -- List of Commanders
	local brnSubComs = brain:GetListOfUnits(categories.SUBCOMMANDER, false)  -- List of Sub Commanders
	-- List of Power Gens including HydroCarbons and Paragons
	local brnPowerGens = brain:GetListOfUnits(categories.ENERGYPRODUCTION, false) 

	for index, curCom in brnComs do
		curCalcEnrgProd = curCom:GetProductionPerSecondEnergy() + curCalcEnrgProd
	end -- Commanders Loop
	for index, curSCom in brnSubComs do
		curCalcEnrgProd = curSCom:GetProductionPerSecondEnergy() + curCalcEnrgProd
	end -- Sub-Commanders Loop
	
	for index, curPowerGen in brnPowerGens do
	    if(curPowerGen:GetFractionComplete() == 1) then
			curCalcEnrgProd = curPowerGen:GetProductionPerSecondEnergy() + curCalcEnrgProd
		end
	end -- Mass Extractor/Fab Loop
	
	return curCalcEnrgProd
end

function djo_CalcMassProd(brain)
	local curCalcMassProd = 0

	local brnComs = brain:GetListOfUnits(categories.COMMAND, false)  -- List of Commanders
	local brnSubComs = brain:GetListOfUnits(categories.SUBCOMMANDER, false)  -- List of Sub Commanders
	local brnMassExtFabs = brain:GetListOfUnits(categories.MASSPRODUCTION, false)  -- List of Extractors and Fabs including Paragons
	local brnHydros = brain:GetListOfUnits(categories.HYDROCARBON, false)  -- List of Hydrocarbons
	-- yes T4 hydro has 2 mass/sec, we don't know why

	for index, curCom in brnComs do
		curCalcMassProd = curCom:GetProductionPerSecondMass() + curCalcMassProd
	end -- Commanders Loop
	for index, curSCom in brnSubComs do
		curCalcMassProd = curSCom:GetProductionPerSecondMass() + curCalcMassProd
	end -- Sub-Commanders Loop
	for index, curMassEF in brnMassExtFabs do
		curCalcMassProd = curMassEF:GetProductionPerSecondMass() + curCalcMassProd
	end -- Mass Extractor/Fab Loop
	for index, curHydros in brnHydros do
		curCalcMassProd = curHydros:GetProductionPerSecondMass() + curCalcMassProd
	end -- Mass Extractor/Fab Loop
	
	return curCalcMassProd
end

function djo_CalcBuildPower(brain)
	local brnEngies = brain:GetListOfUnits(categories.ENGINEER - categories.ENGINEERSTATION, false)
	local curBuildPower = 0
	for index, curEng in brnEngies do
		curBuildPower = curEng:GetBlueprint().Economy.BuildRate + curBuildPower
	end -- Engies Loop
	return curBuildPower
end

function dRound(numIn)
	local dFloor = math.floor
	return dFloor(numIn+0.5)
end
