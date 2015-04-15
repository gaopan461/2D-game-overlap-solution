local os = require 'os'

local Position = {
	{name = 'A', pos = 2},
	{name = 'B', pos = 4},
	{name = 'C', pos = 6},
	{name = 'D', pos = 7},
	{name = 'E', pos = 9},
}

local MAX_POS = 10
local MIN_DIST = 2

function Sleep( ms )
	local cmd = string.format("ping 127.0.0.1 -n 3 -w %d > nul", ms)
	os.execute(cmd)
end

function Print()
	local axis = {}
	for i = 1, MAX_POS do
		axis[i] = '_'
	end

	for _, unit in ipairs(Position) do
		axis[unit.pos] = unit.name
	end

	print(table.concat(axis, ''))
end

function CalcDistance( unit1, unit2 )
	return math.abs(unit2.pos - unit1.pos)
end

function CalcFromUpForce( index )
	local unitCurr = Position[index]
	if index > 1 then
		local unitUp = Position[index-1]
		local dist = CalcDistance(unitUp, unitCurr)
		if dist < MIN_DIST then
			return 1
		elseif dist == MIN_DIST then
			return CalcFromUpForce(index-1)
		else
			return 0
		end
	else
		if unitCurr.pos <= 1 then
			return "TOP"
		else
			return 0
		end
	end
end

function CalcFromDownForce( index )
	local unitCurr = Position[index]
	if index < #Position then
		local unitDown = Position[index+1]
		local dist = CalcDistance(unitCurr, unitDown)
		if dist < MIN_DIST then
			return 1
		elseif dist == MIN_DIST then
			return CalcFromDownForce(index+1)
		else
			return 0
		end
	else
		if unitCurr.pos >= MAX_POS then
			return "BOTTOM"
		else
			return 0
		end
	end
end

function CalcForce()
	for index, unit in ipairs(Position) do
		local fromUpForce = CalcFromUpForce(index)
		local fromDownForce = CalcFromDownForce(index)

		-- 两端都遇到墙了
		if fromUpForce == "TOP" and fromDownForce == "BOTTOM" then
			fromUpForce = 1
			fromDownForce = 1
		-- 仅上面遇到墙
		elseif fromUpForce == "TOP" then
			if fromDownForce > 0 then
				fromUpForce = 1
			else
				fromUpForce = 0
			end
		-- 仅下面遇到墙
		elseif fromDownForce == "BOTTOM" then
			if fromUpForce > 0 then
				fromDownForce = 1
			else
				fromDownForce = 0
			end
		-- 两端都未遇到墙	
		else
			-- do nothing
		end
		unit.force = fromDownForce - fromUpForce
	end
end

function HasForce()
	for _, unit in ipairs(Position) do
		if unit.force ~= 0 then
			return true
		end
	end

	return false
end

function MoveStep()
	for _, unit in ipairs(Position) do
		if unit.force > 0 then
			unit.pos = unit.pos - 1
		elseif unit.force < 0 then
			unit.pos = unit.pos + 1
		else
			-- do nothing
		end
	end
end

function main()
	Print()
	CalcForce()
	while HasForce() do
		MoveStep()
		Print()
		Sleep(1000)
		CalcForce()
	end
end

main()