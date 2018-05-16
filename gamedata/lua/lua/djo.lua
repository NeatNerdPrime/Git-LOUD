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
local logIncrement = 10 -- in seconds

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function djoFn(Brains)
	local outputStringLine = ""
	--LOG( 'DJO: Current Brain Mass Income:' .. GetArmyStat( brain, "Economy_Income_Mass", 0.0 ).Value )
	if(firstRunComplete == 0) then
		firstRunComplete = 1
		numBrains = tablelength(Brains)
		LOG( 'DJO: DJO hooked in and ready to log data' )
		LOG( 'DJO: num brains = ' .. numBrains)
		outputStringLine = outputStringLine .. "Time" .. ","
		for i = 1,numBrains do
			outputStringLine = outputStringLine .. "Brain_" .. i .. "_" .. "MassInc" .. ","
			outputStringLine = outputStringLine .. "Brain_" .. i .. "_" .. "EnrgInc" .. ","
		end
		LOG('DJO:' .. outputStringLine)
	end
	
	if( GetGameTimeSeconds() > nextLogTime ) then
		outputStringLine = ""
		nextLogTime = nextLogTime + logIncrement
		outputStringLine = outputStringLine .. GetGameTimeSeconds() .. ","
		for index, brain in Brains do
			outputStringLine = outputStringLine .. GetArmyStat( brain, "Economy_Income_Mass", 0.0).Value .. ","
			outputStringLine = outputStringLine .. GetArmyStat( brain, "Economy_Income_Energy", 0.0).Value .. ","
		end	-- Brains For Loop
		LOG('DJO:' .. outputStringLine)

	end -- Main time limiting loop
	
end -- End djoFn
