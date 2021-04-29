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

function inPosition ( x, y, width, height )
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	cx, cy = ( cx * sx ), ( cy * sy )
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end