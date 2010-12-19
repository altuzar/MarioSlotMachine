
display.setStatusBar( display.HiddenStatusBar ) --Hide status bar from the beginning

local mainGroup = display.newGroup()

local initialSpeed = 24
local brakes = .5
local speed = { initialSpeed, initialSpeed, initialSpeed, initialSpeed, initialSpeed + 2, initialSpeed + 2}
local stopping = { 0, 0, 0, 0, 0, 0 } -- 0 = false, 1 = stopping, 2 = stopped

local imgs = {}
local sufs = { "Top", "Top", "Med", "Med", "Bot", "Bot" }
local hs = { 115, 115, 112, 112, 93, 93 }
local ys = { 57, 57, 171, 171, 273, 273 }
local offsets = { 50, 50, 10, 10, 150, 150 }
local touched = 0

for i=1,6 do
	imgs[i] = display.newImageRect( "Mario" .. sufs[i] .. ".png" , 1078, hs[i] )
	imgs[i]:setReferencePoint(display.CenterLeftReferencePoint)
	imgs[i].y = ys[i]
	if i%2==0 then
		imgs[i].x = 0 - offsets[i]
	else
		imgs[i].x = imgs[i].width - offsets[i]
	end		
	mainGroup:insert( imgs[i] )
end

local function applyMotion(i)
	if i < 3 or i > 4 then 
		if imgs[i].x <= imgs[i].width * -1 then
			imgs[i].x = imgs[i].x + ( imgs[i].width * 2 ) - speed[i]
		else
			imgs[i].x = math.floor( imgs[i].x - speed[i] )
		end
	else
		if imgs[i].x >= imgs[i].width then
			imgs[i].x = imgs[i].x - ( imgs[i].width * 2 ) + speed[i]
		else
			imgs[i].x = math.floor( imgs[i].x + speed[i] )
		end		
	end
end

local function gameLoop()
	for i=1,6 do
		applyMotion(i)
	end
end

local function main()
	Runtime:addEventListener( "enterFrame", gameLoop )
	return true
end

-- Begin
main()
