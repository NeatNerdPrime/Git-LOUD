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
-- In main while true loop:
-- djoFn(Brains)

local GetArmyStat = moho.aibrain_methods.GetArmyStat
local firstRunComplete = 0
local nextLogTime = 0
local logIncrement = 10 -- in seconds (debuggins 10 seconds, real run value 5*60)
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
			outputStringLine = outputStringLine .. "Brain_" .. i .. "_" .. "MassInc" .. ","
			outputStringLine = outputStringLine .. "Brain_" .. i .. "_" .. "EnrgInc" .. ","
			outputStringLine = outputStringLine .. "Brain_" .. i .. "_" .. "BldPowr" .. ","
		end
		LOG('DJO:' .. outputStringLine)
	end
	
	if( GetGameTimeSeconds() > nextLogTime ) then
		outputStringLine = ""
		nextLogTime = nextLogTime + logIncrement
		outputStringLine = outputStringLine .. GetGameTimeSeconds() .. ","
		for index, brain in Brains do
			if(not ArmyIsOutOfGame(ArmyBrains[index].ArmyIndex)) then 

				-- Record pre-generated statistics
				outputStringLine = outputStringLine .. GetArmyStat( brain, "Economy_Income_Mass", 0.0).Value*10 .. ","
				outputStringLine = outputStringLine .. GetArmyStat( brain, "Economy_Income_Energy", 0.0).Value*10 .. ","

				-- Build Power: Generate statistic from game data
				local brnEngies = brain:GetListOfUnits(categories.ENGINEER, false)
				local curBuildPower = 0
				for index, curEng in brnEngies do
					curBuildPower = GetBlueprint(brnEngies[index]).Economy.BuildRate + curBuildPower
				end -- Engies Loop
				outputStringLine = outputStringLine .. curBuildPower .. ","

			end -- (out of game) if check
		end	-- Brains For Loop
		LOG('DJO:' .. outputStringLine)
		
	end -- Main time limiting loop
	
	
	
end -- End djoFn


-- simlua LOG(ArmyIsOutOfGame(1))
-- simLua LOG(ArmyIsOutOfGame(ArmyBrains[1].ArmyIndex))
-- simLua LOG(table.getn(ArmyBrains))
--local brnEngies = ArmyBrains[1]:GetListOfUnits(categories.ENGINEER - categories.COMMAND, false)
--	local djoBrains = ArmyBrains
--	local brain = Brains[1]
-- simlua LOG(GetBlueprint(brnEngies[1]).Economy.BuildRate)
