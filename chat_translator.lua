--@name Chat Translator
--@author PrikolMen:-b
--@includedir starfall_plib
--@shared

local chipName = 'PLib - Chat Translator'

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )

-- http://translate.google.ru/translate_a/t?client=x&text={textToTranslate}&hl=en&sl=en&tl=ru

if (CLIENT) then

    hook.add('PlayerChat', chipName, function( ply, text, isTeam, isDead )

    end)

end
