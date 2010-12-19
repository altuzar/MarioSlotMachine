
display.setStatusBar( display.HiddenStatusBar ) --Hide status bar from the beginning

local mainGroup = display.newGroup()

local imgs = {}
local sufs = { "Top", "Top", "Med", "Med", "Bot", "Bot" }
local hs = { 115, 115, 112, 112, 93, 93 }
local ys = { 57, 57, 171, 171, 273, 273 }

for i=1,6 do
	imgs[i] = display.newImageRect( "Mario" .. sufs[i] .. ".png" , 1078, hs[i] )
	imgs[i]:setReferencePoint(display.CenterLeftReferencePoint)
	imgs[i].y = ys[i]
	if i%2==0 then
		imgs[i].x = 0
	else
		imgs[i].x = imgs[i].width
	end		
	mainGroup:insert( imgs[i] )
end
