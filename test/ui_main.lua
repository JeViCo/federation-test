local scx, scy = guiGetScreenSize( )
local tocolor = tocolor
local menuData = { }
local menuState, onMenuAppear, onPlayerWasted -- Прототипы

local min = math.min
local max = math.max

local menuConfig =
{
	count = 5, -- Количество секций
	offset = 200, -- Расстояние от центра экрана до центра секции (adapt)
	cRadius = 150, -- Радиус круга (adapt)
	imgRadius = 68, -- Размер иконки (adapt)
	contentOffset = 10, -- adapt
	--borderOffset = 30, -- adapt
	animTime = 500, -- Время на анимацию при наведении
	animEasing = 'OutBack', -- Тип анимации при наведении
	appearTime = 250, -- Время на появление секции
	appearEasing = 'OutBack',
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
	if menuData.lock then return end
	if menuState and state or not menuState and not state then return end
	if state then
		menuData.lock = true
		menuData.sections = { }
		for i = 1, menuConfig.count do
			local rot = menuConfig.rotAmount*( i - 1 ) - menuConfig.rotAmount/2 - 180
			local posX, posY = findPosition( scx/2, scy/2, rot, menuConfig.offset )

			menuData.sections[ i ] =
			{
				x = posX, y = posY,
				path = 'assets/images/icon_' .. i .. '.png',
				transition = dxCreateTransition(
					false, 0, menuConfig.contentOffset,
					menuConfig.animTime, menuConfig.animEasing
				),
				gScale = dxCreateTransition(
					false, 0, 1,
					menuConfig.appearTime, menuConfig.appearEasing
				)
			}
			Timer( dxSetTransitionState, menuConfig.appearTime * ( i - 1 ) / 2, 1, menuData.sections[ i ].gScale, true )
		end
		
		addEventHandler( 'onDxTransitionOver', resourceRoot, onMenuAppear )
		addEventHandler( 'onClientRender', root, renderMenu )
		addEventHandler( 'onClientClick', root, onMenuClick )
		addEventHandler( 'onClientPlayerWasted', localPlayer, onPlayerWasted )
		showCursor( true )
		menuState = true
	else
		menuData.lock = true
		menuData.closeFlag = true

		for i = 1, menuConfig.count do
			menuData.sections[ i ].gScale = dxCreateTransition(
				false, 1, 0,
				menuConfig.appearTime, menuConfig.appearEasing
			)
			Timer( dxSetTransitionState, menuConfig.appearTime * ( i - 1 ) / 2, 1, menuData.sections[ i ].gScale, true )
		end

		addEventHandler( 'onDxTransitionOver', resourceRoot, onMenuAppear )
	end
end

function onMenuAppear( ID )
	if not menuData.sections then return end
	if ID ~= menuData.sections[ menuConfig.count ].gScale then return end

	for i = 1, menuConfig.count do
		dxRemoveTransition( menuData.sections[ i ].gScale )
	end

	removeEventHandler( 'onDxTransitionOver', resourceRoot, onMenuAppear )
	menuData.lock = nil

	if menuData.deadFlag and not menuData.closeFlag then
		menuManager( false )
	end
	if not menuData.closeFlag then return end
	removeEventHandler( 'onClientRender', root, renderMenu )
	removeEventHandler( 'onClientClick', root, onMenuClick )
	removeEventHandler( 'onClientPlayerWasted', localPlayer, onPlayerWasted )
	clearTable( menuData )
	showCursor( false )
	menuState = nil
end

function renderMenu( )
	for i = 1, #menuData.sections do
		local sect = menuData.sections[ i ]
		local gScale = max( min( dxGetTransitionValue( sect.gScale ) or 1, 1 ), 0 )
		local gColor = tocolor( 255, 255, 255, gScale * 255 )

		local cOffset = dxGetTransitionValue( menuData.sections[ i ].transition )
		local cScale = cOffset/menuConfig.contentOffset
		local cAlpha = max( min( cScale, 1 ), 0 ) * gScale * 255

		dxDrawImage(
			sect.x - ( menuConfig.cRadius/2 + cOffset ) * gScale,
			sect.y - ( menuConfig.cRadius/2 + cOffset ) * gScale,
			( menuConfig.cRadius + cOffset*2 ) * gScale,
			( menuConfig.cRadius + cOffset*2 ) * gScale,
			'assets/images/ring.png', 0,0,0, gColor
		)
		dxDrawImage(
			sect.x - menuConfig.cRadius/2 * gScale,
			sect.y - menuConfig.cRadius/2 * gScale,
			menuConfig.cRadius * gScale,
			menuConfig.cRadius * gScale,
			'assets/images/circle.png', 0,0,0, gColor
		)
		dxDrawImage(
			sect.x - menuConfig.imgRadius/2 * gScale,
			sect.y - ( menuConfig.imgRadius/2 + cOffset ) * gScale,
			menuConfig.imgRadius * gScale,
			menuConfig.imgRadius * gScale,
			sect.path, 0,0,0, gColor
		)
		dxDrawText(
			menuConfig.content[ i ].title,
			sect.x - menuConfig.imgRadius/1.75 * gScale,
			sect.y + ( menuConfig.imgRadius/2 + cOffset ) * gScale,
			sect.x + menuConfig.imgRadius/1.75 * gScale,
			sect.y + ( menuConfig.imgRadius/2 + cOffset ) * gScale,
			tocolor( 0, 0, 0, cAlpha, 255 ), cScale * 0.5 + 1, -- adapt
			'default', 'center', 'center'
		)

		local inPos = inPosition( sect.x, sect.y, menuConfig.cRadius ) and not menuData.lock

		if sect.selected and not inPos then
			dxSetTransitionState( menuData.sections[ i ].transition, false )
			sect.selected = nil
		elseif not sect.selected and inPos then
			menuData.sections[ i ].selected = true
			dxSetTransitionState( menuData.sections[ i ].transition, true )
		end
	end
end

function onMenuClick( button, state )
	if button ~= 'left' or state ~= 'up' then return end
	if menuData.lock then return end
	for i = 1, #menuData.sections do
		local sect = menuData.sections[ i ]
		if inPosition( menuData.sections[ i ].x, 	menuData.sections[ i ].y, menuConfig.cRadius ) then
			print( string.format( 'Clicked element: \'%s\'!', menuConfig.content[ i ].title ) )
			break
		end
	end
end

function onPlayerWasted( )
	if menuData.lock then
		menuData.deadFlag = true
	else
		menuManager( false )
	end
end

addCommandHandler('testMenu', function( )
	menuManager( not menuState )
end)