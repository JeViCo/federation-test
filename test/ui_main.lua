local scx, scy = guiGetScreenSize( )
local menuData = { }
local menuState

local menuConfig = {
	section = {
		count = 5, -- Количество секций
		offset = 200, -- Расстояние от центра экрана до центра секции (adapt)
		cRadius = 150, -- Радиус круга (adapt)
		imgRadius = 68, -- Размер иконки (adapt)
	}
}
menuConfig.rotAmount = 360 / menuConfig.section.count

function menuManager( state )
	if menuState and state or not menuState and not state then return end
	if state then
		menuData.sections = { }
		for i = 1, menuConfig.section.count do
			local rot = menuConfig.rotAmount*i - menuConfig.rotAmount/2
			local posX, posY = findPosition( scx/2, scy/2, rot, menuConfig.section.offset )
			menuData.sections[ i ] = {
				x = posX, y = posY, -- no adapt
				path = 'assets/images/icon_' .. i .. '.png'
			}
		end

		addEventHandler( 'onClientRender', root, renderMenu )
		showCursor( true )
		menuState = true
	else
		removeEventHandler( 'onClientRender', root, renderMenu )
		clearTable( menuData )
		showCursor( false )
		menuState = nil
	end
end

function renderMenu( )
	for i = 1, #menuData.sections do
		dxDrawImage(
			menuData.sections[ i ].x - menuConfig.section.cRadius * 0.5,
			menuData.sections[ i ].y - menuConfig.section.cRadius * 0.5,
			menuConfig.section.cRadius, menuConfig.section.cRadius,
			'assets/images/circle.png'
		)
		dxDrawImage(
			menuData.sections[ i ].x - menuConfig.section.imgRadius/2,
			menuData.sections[ i ].y - menuConfig.section.imgRadius/2,
			menuConfig.section.imgRadius, menuConfig.section.imgRadius,
			menuData.sections[ i ].path
		)
	end
end

addCommandHandler('testMenu', function( )
	menuManager( not menuState )
end)

menuManager(true)