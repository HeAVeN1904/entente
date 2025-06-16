require "Data\\Campaigns\\missions\\consts.lua"


MustBeInitialized = true


PlayerFr	= 0 -- MyPlayer
PlayerGerm	= 1

Rect = {}
Rect.left	= 	136
Rect.top	=	286
Rect.right	=	149
Rect.bottom	=	316

DefaultParams = {}
DefaultParams.AiLevel		=	GROUP_AI_LEVEL_AUTONOM
DefaultParams.TemplateType	=	TEMPLATE_TYPE_RECT
DefaultParams.TemplateCount	=	0
DefaultParams.TargetType	=	TARGET_TYPE_PLACE
DefaultParams.TargetPlayer	=	1
DefaultParams.TargetNum		=	0
DefaultParams.MayDismiss	=	true
DefaultParams.NoGroup		=	true

--[[
<localization>
IDS_CAMPAIGN_INFO_NIVEL_START
Нам надо приготовиться к наступлению на позиции противника. Учтите, что немцы построили очень мощную оборонительную линию, для её прорыва Вам понадобится не менее 3 тысяч солдат и 200 конников. Особое внимание рекомендуется уделить подготовке артиллерийских частей.
<ids end>
IDS_CAMPAIGN_INFO_NIVEL_PLAYER_LOST
Огромное количество жизней, которое мы потеряли в этом наступлении не дали нам ничего. Это самое страшное наше поражение за всю историю.
<ids end>
IDS_CAMPAIGN_INFO_NIVEL_PLAYER_WIN
Несмотря на Ваши умелые действия мы понесли очень серьёзные потери при попытке прорыва обороны противника. Это вынуждает нас временно прервать наступление и ждать появления средств, которые позволят нам более успешно действовать против плотных оборонительных позиций...
<ids end>
IDS_CAMPAIGN_INFO_NIVEL_DEFEND_BASE
Противник решил провести атаку на нашу базу. Остановите его, иначе нам придется снова отложить наступление.
<ids end>
IDS_CAMPAIGN_INFO_NIVEL_DEFEND_BASE_COMPLETE
Отлично, теперь у нас достаточно сил для прорыва немецкой обороны.
Для начала нам необходимо захватить опорную базу противника. При этом вы не должны потерять более 10 тысяч человек.
<ids end>
IDS_CAMPAIGN_INFO_NIVEL_GET_ENEMY_BASE_COMPLETE
Фрицы оказались гораздо хитрее, чем мы думали. Оказывается, они уже давно отвели свои главные силы с первой линии обороны, и теперь наверняка готовятся к контрнаступлению на наши позиции.
Готовьтесь к обороне. Мы должны удержать эту землю любой ценой.
<ids end>
IDS_CAMPAIGN_INFO_NIVEL_LOSTSTOBIG
Огромное количество жизней, которое мы потеряли в этом наступлении не дали нам ничего. Это самое страшное наше поражение за всю историю.
<ids end>
</localization>
]]

function Init()
	StartTime = GetTime()

	IsFirstTaskDone = false
	IsSecondTaskDone = false
	IsThirdTaskDone = false
	IsLastAttackStart = false

	PlayerKilledUnitsBeforeThirdTask = -1
	TimeForLastAttack = 0

	UnitsGroup_Create(	"FirstAttackers")
	Rect.left	= 132
	Rect.top	= 323
	Rect.right	= 150
	Rect.bottom	= 367
	UnitsGroup_AddInRect(	"FirstAttackers", Rect, PlayerGerm, UNIT_ALL, 65535)

	UnitsGroup_Create(	"MainForces")
	Rect.left	= 78
	Rect.top	= 101
	Rect.right	= 121
	Rect.bottom	= 207
	UnitsGroup_AddInRect(	"MainForces", Rect, PlayerGerm, UNIT_ALL, 65535)

	MessageBox("IDS_CAMPAIGN_INFO_NIVEL_START") -- ‚ ¬ ­ ¤® Ї®¤Ј®в®ўЁвбп......
end


function EveryThingLost(aPlayer)

	if GetPlayerStatsUnits(aPlayer) > 0 or GetPlayerStatsHouses(aPlayer) > 0 then
		return false
	else
		return true
	end

end


function main()

	if MustBeInitialized == true then
		Init()
		MustBeInitialized = false
	end

	if EveryThingLost(PlayerFr) then

		-- ‡¤Ґбм ¬®¦­® б¤Ґ« вм бўЁвз ¤«п ўлў®¤  а §­ле б®®ЎйҐ­Ё©
		MessageBox("IDS_CAMPAIGN_INFO_NIVEL_PLAYER_LOST")
		LuaManager_StopCurrentScript(PlayerGerm)
		
	elseif EveryThingLost(PlayerGerm) then
		
		MessageBox("IDS_CAMPAIGN_INFO_NIVEL_PLAYER_WIN")
		LuaManager_StopCurrentScript(PlayerFr)

	end

	if not(IsFirstTaskDone) then

		if (GetTime() - StartTime) > 60*5 then

			IsFirstTaskDone = true
			MessageBox("IDS_CAMPAIGN_INFO_NIVEL_DEFEND_BASE") -- Џа®вЁў­ЁЄ аҐиЁ« Їа®ўҐбвЁ  в Єг.....

			UnitsGroup_SendToMulti("FirstAttackers", 183, 360, DefaultParams)

	
		end

	elseif not(IsSecondTaskDone) then

		if UnitsGroup_GetUnitsQuantity("FirstAttackers") < 5 then
			
			IsSecondTaskDone = true

			OpenMapToPlayer(148, 256, 10)
			SetCamera(148, 256)

			MessageBox("IDS_CAMPAIGN_INFO_NIVEL_DEFEND_BASE_COMPLETE") -- Ћв«Ёз­®, вҐЇҐам г ­ б ¤®бв в®з­® бЁ« .....

			PlayerKilledUnitsBeforeThirdTask = GetPlayerStatsKilled(PlayerFr)

		end

	elseif not(IsThirdTaskDone) then

		AddMessage("IDS_LUA_MESSAGE_YOU_LOSTS", GetPlayerStatsKilled(PlayerFr) - PlayerKilledUnitsBeforeThirdTask, "IDS_LUA_MESSAGE_UNITS")

		if (GetPlayerStatsKilled(PlayerFr) - PlayerKilledUnitsBeforeThirdTask) > 1000 then
			
			MessageBox("IDS_CAMPAIGN_INFO_NIVEL_LOSTSTOBIG")
			LuaManager_StopCurrentScript(PlayerGerm)

		elseif IsPlayerHouseInArea(137, 225, 151, 285, PlayerGerm, HOUSE_ALL) == false then

			IsThirdTaskDone = true
			MessageBox("IDS_CAMPAIGN_INFO_NIVEL_GET_ENEMY_BASE_COMPLETE") -- ”аЁжл ®Є § «Ёбм Ј®а §¤® еЁваҐҐ,....
			TimeForLastAttack = GetTime() + 1*60

		end

	elseif not(IsLastAttackStart) then

		if GetTime() > TimeForLastAttack then
			IsLastAttackStart = true

			UnitsGroup_SendToMulti("MainForces", 148, 258, DefaultParams)

			SetPlayerAIType(PlayerGerm, AITypeAttackConst)

		end

	else

		if UnitsGroup_GetUnitsQuantity("MainForces") < 20 then

			MessageBox("IDS_CAMPAIGN_INFO_NIVEL_PLAYER_WIN")
			LuaManager_StopCurrentScript(PlayerFr)

		elseif not(IsPlayerUnitInArea(133, 190, 159, 286, PlayerFr)) then

			MessageBox("IDS_CAMPAIGN_INFO_NIVEL_PLAYER_LOST")
			LuaManager_StopCurrentScript(PlayerGerm)

		end

	end


end