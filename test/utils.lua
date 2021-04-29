function clearTable ( t )
	if type ( t ) ~= 'table' then return end
	for k, v in pairs ( t ) do
		if type ( v ) == 'table' then
			clearTable(v)
		end
		t[ k ] = nil
	end
end

function findPosition( x, y, rot, offset )
	return
		x - math.sin ( math.rad ( rot ) ) * ( offset or 1 ),
		y + math.cos ( math.rad ( rot ) ) * ( offset or 1 )
end

function inPosition ( x, y, radius )
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	cx, cy = ( cx * sx ), ( cy * sy )
	return (cx - x)^2 + (cy - y)^2 < (radius/2)^2
end

local transitions = { }
local min = math.min

function dxCreateTransition( bool, from, to, time, easing )
	local ID = 1
	while transitions[ ID ] do
		ID = ID + 1
	end

	transitions[ ID ] = {
		state = bool,
		time = time or 1000,
		tick = getTickCount( ),
		easing = easing or 'Linear',
		startPoint = from, endPoint = to,
		timer = Timer( triggerEvent, time, 1, 'onDxTransitionOver', resourceRoot, ID )
	}

	if bool then
		transitions[ ID ].active = true
		transitions[ ID ].timer = Timer ( onDxTransitionOver, time, 1, ID )
		transitions[ ID ].from, transitions[ ID ].to = from, to
	else
		transitions[ ID ].tick = transitions[ ID ].tick - transitions[ ID ].time
		transitions[ ID ].from, transitions[ ID ].to = to, from
	end

	return ID
end

function dxRemoveTransition( ID )
	if not transitions[ ID ] then return false end
	if transitions[ ID ].timer and transitions[ ID ].valid then
		transitions[ ID ].timer:destroy( )
	end
	clearTable( transitions[ ID ] )
	transitions[ ID ] = nil
end

function dxGetTransitionValue ( ID )
	if not transitions[ ID ] then return false end
	local progress = ( getTickCount ( ) - transitions[ ID ].tick ) / transitions[ ID ].time

	return transitions[ ID ].from + ( transitions[ ID ].to - transitions[ ID ].from )
		* getEasingValue ( min ( progress, 1 ), transitions[ ID ].easing )
end

function dxSetTransitionState ( ID, bool )
	if not transitions[ ID ] then return false end
	if transitions[ ID ].state == bool then return true end

	transitions[ ID ].state = bool
	transitions[ ID ].from = dxGetTransitionValue ( ID )
	transitions[ ID ].to = bool and transitions[ ID ].endPoint or transitions[ ID ].startPoint
	transitions[ ID ].tick = getTickCount ( )

	local timeleft = transitions[ ID ].time

	if transitions[ ID ].timer and transitions[ ID ].timer.valid then
		timeleft = timeleft - transitions[ ID ].timer:getDetails( )
		transitions[ ID ].timer:destroy ( )
	end
	transitions[ ID ].active = true
	transitions[ ID ].timer = Timer( triggerEvent, timeleft, 1, 'onDxTransitionOver', resourceRoot, ID )
	return true
end

addEvent( 'onDxTransitionOver', false )