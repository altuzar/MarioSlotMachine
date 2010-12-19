--[[
-- utilidades 
--]]

function print_r (t, indent, done)
  done = done or {}
  indent = indent or ''
  local nextIndent -- Storage for next indentation value
  for key, value in pairs (t) do
    if type (value) == "table" and not done [value] then
      nextIndent = nextIndent or
          (indent .. string.rep(' ',string.len(tostring (key))+2))
          -- Shortcut conditional allocation
      done [value] = true
      print (indent .. "[" .. tostring (key) .. "] => Table {");
      print  (nextIndent .. "{");
      print_r (value, nextIndent .. string.rep(' ',2), done)
      print  (nextIndent .. "}");
    else
      print  (indent .. "[" .. tostring (key) .. "] => " .. tostring (value).."")
    end
  end
end



function file_get_contents(file)
    local contents = ""
    local file = io.open( file, "r" )
    if file then
       contents = file:read( "*a" )
       io.close( file )
    end
    return contents
end


function showScreen(newScreen, param, effect)
	local effect = (nil == effect) and "flip" or effect
	if "flip" == effect then
		transition.to( currentScreen, { time=350, xScale=.001, x=w/2, onComplete= function()
			loadScreen( newScreen, param )
 			transition.from( currentScreen, { time=350, xScale=.001, x=w/2} )
		end})
	elseif "fade" == effect then
		transition.to(currentScreen, {time=400, alpha=0, onComplete=function()
			loadScreen( newScreen, param )
			transition.from(currentScreen, {time=400, alpha=0})
		end})
	elseif "grow" == effect then
		currentScreen.xReference=w/2
		currentScreen.yReference=h/2
		transition.to(currentScreen, {time=400, alpha=0, xScale=4, yScale=4, onComplete=function()
			loadScreen(newScreen, param)
			currentScreen.xReference=w/2
			currentScreen.yReference=h/2
			transition.from(currentScreen, {time=400, alpha=0, xScale=.01, yScale=.01})
		end})
	elseif "desgrow" == effect then
		currentScreen.xReference=w/2
		currentScreen.yReference=h/2
		transition.to(currentScreen, {time=400, alpha=.8, xScale=.01, yScale=.01, onComplete=function()
			loadScreen(newScreen, param)
			currentScreen.xReference=w/2
			currentScreen.yReference=h/2
			transition.from(currentScreen, {time=400, alpha=0, xScale=4, yScale=4})
		end})
	elseif "slideLeft" == effect then
		transition.to(currentScreen, {time=150, x=-(currentScreen.width), onComplete=function()
			loadScreen(newScreen, param)
			transition.from(currentScreen, {time=150, x=(currentScreen.width)})
		end})
	else 
		loadScreen( newScreen, param )
	end
end



function loadScreen(newScreen, param)
	if currentScreen then
		currentScreen:cleanUp()
	end
	currentScreen = require("screens/"..newScreen).new(param)
	mainView:insert(currentScreen)
	
	--Save the screen name for the previous state variables
	lastScreen = newScreen
	return true
end
