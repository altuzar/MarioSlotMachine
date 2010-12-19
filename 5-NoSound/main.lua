
require "util"
local easingx =  require "easing"

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
local prizes = {}
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

local function givePrize()
	local lab
	print(prizes[1], prizes[2], prizes[3])
	if prizes[1] == prizes[2] and prizes[2] == prizes[3] then
		lab = prizes[1] .. " UP"
	else 
		lab = "N00B"
	end
	animatePrize(lab)
end

-- aplica la animacion de la imagen que se está deteniendo
local function animateStop(i)
	local prize = { 5, 2, 3, 2 }
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
				speed[i+1] = 0
				stopping[i+1] = 2 
			end
			
			-- esto aun no se si va aqui
			table.insert(prizes, prize[t]) 
			if #prizes >= 3 then
				givePrize()
				prizes = {}
			end
		end
	end
end

-- esta funcion va quitandole velocidad al movimiento de la imagen
-- cuando la velocidad es menor o igual a 8 se muestra el efecto de BOUNCE
local function applyBrakes(i)
	if stopping[i] == 1 and speed[i] > 8 then
		speed[i] = speed[i] - brakes
	end
	if stopping[i] == 1 and speed[i] <= 8 then
		animateStop(i)
	end
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
	-- Algunas de estos loops deberían enviarse a un par de funciones
	for i=1,6 do
		applyBrakes(i)
		applyMotion(i)
	end
end

local onScreenTouch = function( event )
	if event.phase == "began" then
		touched = touched + 1
		if stopping[5] == 2 then
			speed = { initialSpeed, initialSpeed, initialSpeed, initialSpeed, initialSpeed + 2, initialSpeed + 2}
			stopping = { 0, 0, 0, 0, 0, 0 } -- 0 = false, 1 = stopping, 2 = stopped
			touched = 0
			return
		end
		if (touched >= 4) then
			return
		end
		for i=1,5,2 do
			if stopping[i] == 0 then
				stopping[i] = 1
				stopping[i+1] = 1
				break
			end
		end
	end
end

local function main()
	Runtime:addEventListener( "enterFrame", gameLoop )
	Runtime:addEventListener( "touch", onScreenTouch )
	return true
end

-- Begin
main()
