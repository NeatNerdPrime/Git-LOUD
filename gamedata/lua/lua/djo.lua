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
local nextLogTime = 0
local logIncrement = 10 --5*60 -- in seconds (debuggins 10 seconds, real run value 5*60)
local GetListOfUnits = moho.aibrain_methods.GetListOfUnits

function djoFn(Brains)
	local outputStringLine = ""
	--LOG( 'DJO: Current Brain Mass Income:' .. GetArmyStat( brain, "Economy_Income_Mass", 0.0 ).Value )
	if(firstRunComplete == 0) then
		firstRunComplete = 1
		numBrains = table.getn(Brains)  -- change to table.getn
		LOG( 'DJO: DJO hooked in and ready to log data' )
		LOG( 'DJO: num brains = ' .. numBrains)
		outputStringLine = outputStringLine .. "Time" .. ","

		-- Add one line below for each statistic to be tracked
		for i = 1,numBrains do
			outputStringLine = outputStringLine .. "Brain" .. i .. "_" .. "MassInc" .. ","
			outputStringLine = outputStringLine .. "Brain" .. i .. "_" .. "EnrgInc" .. ","
			outputStringLine = outputStringLine .. "Brain" .. i .. "_" .. "BldPowr" .. ","
			outputStringLine = outputStringLine .. "Brain" .. i .. "_" .. "MassIn" .. ","
		end
		LOG('DJO:' .. outputStringLine)
	end
	
	if( GetGameTimeSeconds() > nextLogTime ) then
		outputStringLine = ""
		nextLogTime = nextLogTime + logIncrement
		outputStringLine = outputStringLine .. GetGameTimeSeconds() .. ","
		for index, brain in Brains do
			if(not ArmyIsOutOfGame(ArmyBrains[index].ArmyIndex)) then 

				-- **** Game generatored Mass/Energy Stats
				outputStringLine = outputStringLine .. GetArmyStat( brain, "Economy_Income_Mass", 0.0).Value*10 .. ","
				outputStringLine = outputStringLine .. GetArmyStat( brain, "Economy_Income_Energy", 0.0).Value*10 .. ","

				-- **** Build Power
				local curBuildPower = 0
				local brnEngies = brain:GetListOfUnits(categories.ENGINEER - categories.ENGINEERSTATION, false)
				
				for index, curEng in brnEngies do
					curBuildPower = curEng:GetBlueprint().Economy.BuildRate + curBuildPower
				end -- Engies Loop
				outputStringLine = outputStringLine .. curBuildPower .. ","

				-- **** Improved Mass Algo
				local curCalcMassProd = 0
				local brnComs = brain:GetListOfUnits(categories.COMMAND, false)  -- List of Commanders
				local brnSubComs = brain:GetListOfUnits(categories.SUBCOMMANDER, false)  -- List of Sub Commanders
				local brnMassExtFabs = brain:GetListOfUnits(categories.MASSPRODUCTION, false)  -- List of Extractors and Fabs
				local brnHydros = brain:GetListOfUnits(categories.HYDROCARBON, false)  -- List of Hydrocarbons
				-- yes T4 hydro has 2 mass/sec, we don't know why

				for index, curCom in brnComs do
					curCalcMassProd = curCom:GetProductionPerSecondMass() + curCalcMassProd
				end -- Commanders Loop
				for index, curSCom in brnSubComs do
					curCalcMassProd = curSCom:GetProductionPerSecondMass() + curCalcMassProd
				end -- Sub-Commanders Loop
				for index, curMassEF in brnMassExtFabs do
					curCalcMassProd = curMassEF:GetBlueprint().Economy.ProductionPerSecondMass + curCalcMassProd
				end -- Mass Extractor/Fab Loop
				for index, curHydros in brnHydros do
					curCalcMassProd = curHydros:GetProductionPerSecondMass() + curCalcMassProd
				end -- Mass Extractor/Fab Loop
				outputStringLine = outputStringLine .. curCalcMassProd .. ","
			
			else 
				outputStringLine = outputStringLine .. 0 .. ","
				outputStringLine = outputStringLine .. 0 .. ","
				outputStringLine = outputStringLine .. 0 .. ","
				outputStringLine = outputStringLine .. 0 .. ","
			end -- (out of game) if check
		end	-- Brains For Loop
		LOG('DJO:' .. outputStringLine)
		
	end -- Main time limiting if statement
	
	
	
end -- End djoFn


-- simlua LOG(ArmyIsOutOfGame(1))
-- simLua LOG(ArmyIsOutOfGame(ArmyBrains[1].ArmyIndex))
-- simLua LOG(table.getn(ArmyBrains))
--local brnEngies = ArmyBrains[1]:GetListOfUnits(categories.ENGINEER - categories.COMMAND, false)
--	local djoBrains = ArmyBrains
--	local brain = Brains[1]
-- simlua LOG(GetBlueprint(brnEngies[1]).Economy.BuildRate)
