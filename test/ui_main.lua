local scx, scy = guiGetScreenSize( )
local tocolor = tocolor
local menuData = { }
local menuState

local menuConfig =
{
	count = 5, -- Количество секций
	offset = 200, -- Расстояние от центра экрана до центра секции (adapt)
	cRadius = 150, -- Радиус круга (adapt)
	imgRadius = 68, -- Размер иконки (adapt)
	contentOffset = 10, -- adapt
	--borderOffset = 30, -- adapt
	animTime = 500,
	animEasing = 'InOutQuad',
	content =
	{
		{
			title = 'Measure'
		},
		{
			title = 'Tools'
		},
		{
			title = 'Scissors'
		},
		{
			title = 'Brush'
		},
		{
			title = 'Pencil'
		},
	}
}
menuConfig.rotAmount = 360 / menuConfig.count

function menuManager( state )
	if menuState and state or not menuState and not state then return end
	if state then
		menuData.sections = { }
		for i = 1, menuConfig.count do
			local rot = menuConfig.rotAmount*i - menuConfig.rotAmount/2
			local posX, posY = findPosition( scx/2, scy/2, rot, menuConfig.offset )

			menuData.sections[ i ] =
			{
				x = posX, y = posY,
				path = 'assets/images/icon_' .. i .. '.png',
				transition = dxCreateTransition(
					false, 0, menuConfig.contentOffset,
					menuConfig.animTime, menuConfig.animEasing
				)
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
		local sect = menuData.sections[ i ]
		local cOffset = dxGetTransitionValue( menuData.sections[ i ].transition )
		local scale = cOffset/menuConfig.contentOffset

		dxDrawImage(
			sect.x - menuConfig.cRadius/2,
			sect.y - menuConfig.cRadius/2,
			menuConfig.cRadius,
			menuConfig.cRadius,
			'assets/images/circle.png'
		)
		dxDrawImage(
			sect.x - menuConfig.imgRadius/2,
			sect.y - menuConfig.imgRadius/2 - cOffset,
			menuConfig.imgRadius,
			menuConfig.imgRadius,
			sect.path
		)

		dxDrawText(
			menuConfig.content[ i ].title,
			sect.x - menuConfig.imgRadius / 1.75,
			sect.y + menuConfig.imgRadius / 2 + cOffset,
			sect.x + menuConfig.imgRadius / 1.75,
			sect.y + menuConfig.imgRadius / 2 + cOffset,
			tocolor( 0, 0, 0, scale * 255 ), scale * 0.5 + 1, -- adapt
			'default', 'center', 'center'
		)

		local inPos = inPosition(
			sect.x,
			sect.y,
			menuConfig.cRadius
		)
		
		if sect.selected and not inPos then
			dxSetTransitionState( menuData.sections[ i ].transition, false )
			sect.selected = nil
		elseif not sect.selected and inPos then
			menuData.sections[ i ].selected = true
			dxSetTransitionState( menuData.sections[ i ].transition, true )
		end
	end
end

addCommandHandler('testMenu', function( )
	menuManager( not menuState ) -- Добавить анимацию при появлении Timer + 
end)

menuManager( true )