
-- Util is just for a print_r, and other debug stuff
require "util"

-- The elastic easing for the transitions. Still don't quite like it 100%, but for now is OK
local easingx =  require "easing"

-- Bye Statusbar
display.setStatusBar( display.HiddenStatusBar ) 

-- Graphics group
local mainGroup = display.newGroup()

-- Lots of arrays and vars
local initialSpeed = 24
local brakes = .5
local speed = { initialSpeed, initialSpeed, initialSpeed, initialSpeed, initialSpeed + 2, initialSpeed + 2}
local stopping = { 0, 0, 0, 0, 0, 0 } -- 0 = false, 1 = stopping, 2 = stopped

local imgs = {}
local sufs = { "Top", "Top", "Med", "Med", "Bot", "Bot" }
local hs = { 115, 115, 112, 112, 93, 93 }
local ys = { 57, 57, 171, 171, 273, 273 }
local offsets = { 50, 50, 10, 10, 150, 150 }
local prizes = {}
local touched = 0

local backSound = audio.loadSound("MarioBack.wav")
local turuSound = audio.loadSound("MarioTuru.wav")
local buuuSound = audio.loadSound("MarioBuuu.wav")
local upSound = audio.loadSound("Mario1up.mp3")

-- Background music, please
backgroundMusicChannel = audio.play( backSound, { loops=-1, fadein=500 } )

-- Create all the images. 2 for each bar. 6 in total.
for i=1,6 do
	imgs[i] = display.newImageRect( "Mario" .. sufs[i] .. ".png" , 1078, hs[i] )
	imgs[i]:setReferencePoint(display.CenterLeftReferencePoint)
	imgs[i].y = ys[i]
	if i%2==0 then
		imgs[i].x = 0 - offsets[i] -- Some offset here, so the images are now static
	else
		imgs[i].x = imgs[i].width - offsets[i]
	end		
	mainGroup:insert( imgs[i] )
end

-- Here comes the 1up!
local function playUp(i)
	audio.play( upSound,  { loops=i-1 } )
end

-- Here comes the Buuuu
local function playBuuu()
	audio.play( buuuSound )
end

-- Some pretty prize animation. 6 white labels for outline + 1 red label for the real text.
local function animatePrize(t)
	local xlab = display.contentWidth * 0.41
	local ylabini = display.contentHeight * 1.5
	local ylabend = display.contentHeight * 0.44
	local xlabs = { -3, -3, 3, 3, 0, 0, 3, -3, 0 }
	local ylabs = { -3, 3, -3, 3, 3, -3, 0, 0, 0 }
	local labs = {}
	for i = 1, #xlabs do
		labs[i] = display.newText(t, xlab + xlabs[i], ylabini + ylabs[i], 
			native.systemFontBold, 32)
		if i == #xlabs then
			labs[i]:setTextColor(255, 0, 0) 
		else
			labs[i]:setTextColor(255, 255, 255) 
		end
		transition.to( labs[i], { time=600, y = ylabend + ylabs[i], xScale = 0.8, yScale = 1.2,
			onComplete=function()
				transition.to( labs[i], { time=200, delay=1200, alpha=0, xScale=4, yScale=4 })
			end })
	end
end

-- Prize Logic. If the 3 array items are equal, we are good.
local function givePrize()
	local lab
	print(prizes[1], prizes[2], prizes[3])
	if prizes[1] == prizes[2] and prizes[2] == prizes[3] then
		lab = prizes[1] .. " UP"
		timer.performWithDelay( 1000, playUp(prizes[1]) )
	else 
		lab = "N00B"
		timer.performWithDelay( 300, playBuuu )		
	end
	animatePrize(lab)
end

-- Stop me now! Lots of problems with the little bump when the image stops. 
local function animateStop(i)
	local prize = { 5, 2, 3, 2 }
	-- This is the real stop X for each item
	local xprize = { 240, -30, -300, -570, -838 }
	local xbump 
	for t = 1,4 do
		if imgs[i].x >= xprize[t] - speed[i] and imgs[i].x <= xprize[t] + speed[i] then
			speed[i] = 0
			stopping[i] = 2
			if i == 3 or i == 4 then
				xbump = xprize[t]+15
			else
				xbump = xprize[t]-15
			end
			imgs[i].x = xprize[t]
			transition.to(imgs[i], {time=200, x=xbump, transition = easingx.easeOutElastic,
				onComplete=function()
					transition.to( imgs[i], { time=200, x=xprize[t], transition = easingx.easeOutElastic })
				end })
			if(i%2==0) then
				imgs[i-1].x = imgs[i].x - imgs[i].width
				transition.to(imgs[i-1], {time=200, x=xbump - imgs[i].width, transition = easingx.easeOutElastic,
					onComplete=function()
						transition.to( imgs[i-1], { time=200, x=xprize[t] - imgs[i].width, transition = easingx.easeOutElastic })
					end })
--				transition.to(imgs[i-1], {time=400, x=xprize[t] - imgs[i].width, transition = easingx.easeOutElastic })
				speed[i-1] = 0
				stopping[i-1] = 2 
			else
				imgs[i+1].x = imgs[i].x - imgs[i].width
				transition.to(imgs[i+1], {time=200, x=xbump - imgs[i].width, transition = easingx.easeOutElastic,
					onComplete=function()
						transition.to( imgs[i+1], { time=200, x=xprize[t] - imgs[i].width, transition = easingx.easeOutElastic })
					end })
--				transition.to(imgs[i+1], {time=400, x=xprize[t] - imgs[i].width, transition = easingx.easeOutElastic })
				speed[i+1] = 0
				stopping[i+1] = 2 
			end
			
			-- If the prizes table is full, give some prize!
			table.insert(prizes, prize[t]) 
			if #prizes >= 3 then
				timer.performWithDelay( 500, audio.pause( backgroundMusicChannel ) )
				givePrize()
				prizes = {}
			end
		end
	end
end

-- Brakes! When the speed is small, go for the stop animation.
local function applyBrakes(i)
	if stopping[i] == 1 and speed[i] > 8 then
		speed[i] = speed[i] - brakes
	end
	if stopping[i] == 1 and speed[i] <= 8 then
		animateStop(i)
	end
end

-- Lets move! Two if's for left-to-right, one for right-to-left. For sure, there is a more elegant way. Please tell me which!
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

-- Main game loop. That's it, a launcher.
local function gameLoop()
	for i=1,6 do
		applyBrakes(i)
		applyMotion(i)
	end
end

-- Touch logic. Almost all the game logic. 
local onScreenTouch = function( event )
	if event.phase == "began" then
		touched = touched + 1
		if stopping[5] == 2 then
			speed = { initialSpeed, initialSpeed, initialSpeed, initialSpeed, initialSpeed + 2, initialSpeed + 2}
			stopping = { 0, 0, 0, 0, 0, 0 } -- 0 = false, 1 = stopping, 2 = stopped
			audio.resume( backgroundMusicChannel )
			touched = 0
			return
		end
		if (touched >= 4) then
			return
		end
		audio.play( turuSound )		
		for i=1,5,2 do
			if stopping[i] == 0 then
				stopping[i] = 1
				stopping[i+1] = 1
				break
			end
		end
	end
end

-- A couple of runtime listeners and that's all.
local function main()
	Runtime:addEventListener( "enterFrame", gameLoop )
	Runtime:addEventListener( "touch", onScreenTouch )
	return true
end

-- Begin!
main()
