-- НАСТРОЙКИ
Run = true;		-- Флаг поддержания работы скрипта
local class = "TQBR"; -- Класс бумаги для выгрузки данных - основной рынок
local sec = "ALRS"; -- Код бумаги
local interval = 10 -- интервал в секундах для выгрузки показателей
--
-- Вызывается терминалом QUIK в момент запуска скрипта
function OnInit()
	-- Создает, или открывает для чтения/добавления файл CSV в той же папке, где находится данный скрипт
	CSV = io.open(getScriptPath().."/MyTrades.csv", "a+");
	-- Встает в конец файла, получает номер позиции
	local Position = CSV:seek("end",0);
	-- Если файл еще пустой
	if Position == 0 then
		-- Создает строку с заголовками столбцов
		local Header = "Time;Last_volume;Last_price;Last_time"
    Header = Header..";Bid;Bid_depth;Bid_depthT;Numbids;Offer;Offer_depth;Offer_depthT;Numoffers"
    for i = 1, 20 do
      Header = Header..";Bid_vol_"..i..";Bid_price_"..i
    end
    for i = 1, 20 do
      Header = Header..";Offer_vol_"..i..";Offer_price_"..i
    end
    Header = Header.."\n"
		-- Добавляет строку заголовков в файл
		CSV:write(Header);
		-- Сохраняет изменения в файле
		CSV:flush();
	end;
end;

-- Вызывается терминалом QUIK в момент остановки скрипта
function OnStop()
	-- Выключает флаг, чтобы остановить цикл while внутри main
	Run = false;
	-- Закрывает открытый CSV-файл
	CSV:close();
end;

-- Подписываемся на данные из стакана по бумаге
Subscribe_Level_II_Quotes(class, sec);

-- Основная функция забора данных, вызывается из main()
function getdata()
    if os.date("%S") % interval == 0 then
         -- Доп.данные
         QuoteStr = os.date()..";"
         QuoteStr = QuoteStr..tonumber(getParamEx(class,  sec, "QTY").param_value)..";"  --Количество в последней сделке
         QuoteStr = QuoteStr..tonumber(getParamEx(class,  sec, "LAST").param_value)..";" --Цена последней сделки
         QuoteStr = QuoteStr..getParamEx(class,  sec, "TIME").param_value..";"           --Время последней сделки
         QuoteStr = QuoteStr..getParamEx(class,  sec, "BID").param_value..";"            --Лучшая цена спроса
         QuoteStr = QuoteStr..getParamEx(class,  sec, "BIDDEPTH").param_value..";"       --Спрос по лучшей цене
         QuoteStr = QuoteStr..getParamEx(class,  sec, "BIDDEPTHT").param_value..";"      --Суммарный спрос
         QuoteStr = QuoteStr..getParamEx(class,  sec, "NUMBIDS").param_value..";"        --Количество заявок на покупку
         QuoteStr = QuoteStr..getParamEx(class,  sec, "OFFER").param_value..";"          --Лучшая цена предложения
         QuoteStr = QuoteStr..getParamEx(class,  sec, "OFFERDEPTH").param_value..";"     --Предложение по лучшей цене
         QuoteStr = QuoteStr..getParamEx(class,  sec, "OFFERDEPTHT").param_value..";"    --Суммарное предложение
         QuoteStr = QuoteStr..getParamEx(class,  sec, "NUMOFFERS").param_value..";"      --Количество заявок на продажу
				 -- Представляет снимок СТАКАНА в виде СТРОКИ
				 ql2 = getQuoteLevel2(class, sec);
         for i = 1, tonumber(ql2.bid_count), 1 do
            if ql2.bid[i].quantity ~= nil then   -- На некоторых ценах могут отсутствовать заявки
               QuoteStr = QuoteStr..tostring(tonumber(ql2.bid[i].quantity))..";"..tostring(tonumber(ql2.bid[i].price))..";";
            else
               QuoteStr = QuoteStr.."0;"..tostring(tonumber(ql2.bid[i].price))..";";
            end;
         end;
         for i = 1, tonumber(ql2.offer_count), 1 do
            if ql2.offer[i].quantity ~= nil then   -- На некоторых ценах могут отсутствовать заявки
               QuoteStr = QuoteStr..tostring(-tonumber(ql2.offer[i].quantity))..";"..tostring(-tonumber(ql2.offer[i].price));
            else
               QuoteStr = QuoteStr.."0;"..tostring(tonumber(ql2.offer[i].price));
            end;
            if i < tonumber(ql2.offer_count) then QuoteStr = QuoteStr..";" end
         end;
   -- Записывает строку в файл
        QuoteStr = QuoteStr.."\n"
        --message(QuoteStr)
	      CSV:write(QuoteStr);
   -- Сохраняет изменения в файле
	      CSV:flush();
    end;
end;

-- Основная функция скрипта (пока работает она, работает скрипт)
function main()
	-- Цикл, поддерживающий работу скрипта
	while Run do
		getdata()
		sleep(1000);
	end;
end;

-- В результате при каждом обновлении стакана по инструменту RTS-6.15 в переменной QuoteStr будет строка, типа:
   -- "15;86130;17;86120;16;86110;22;86100;16;86090;24;86080;26;86070;29;86060;97;86050;51;86040;99;86030;88;86020;143;86010;140;86000;15;85990;49;85980;58;85970;28;85960;49;85950;36;85940;71;85930;115;85920;95;85910;25;85900;5;85890;13;85880;62;85870;3;85860;36;85850;26;85840;11;85830;9;85820;99;85810;86;85800;41;85790;24;85780;2;85770;36;85760;162;85750;22;85740;44;85730;76;85720;229;85710;121;85700;5;85690;5;85680;2;85670;10;85660;148;85650;119;85640;12;86150;19;86160;26;86170;32;86180;71;86190;49;86200;26;86210;20;86220;91;86230;57;86240;47;86250;25;86260;34;86270;41;86280;21;86290;66;86300;36;86310;57;86320;50;86330;34;86340;38;86350;22;86360;17;86370;15;86380;18;86390;13;86400;3;86410;34;86420;29;86430;80;86440;26;86450;68;86460;226;86470;371;86480;30;86490;64;86500;99;86510;11;86520;2;86530;23;86540;9;86550;3;86560;52;86570;23;86580;25;86590;73;86600;17;86610;88;86620;52;86630;150;86640"
   -- Такую строку удобно, в последствии, передавать в C# и разделять на элементы

-- Функция getQuoteLevel2() принимает 2 параметра: Код класса и Код бумаги, а возвращает таблицу, которая имеет следующие поля:
-- bid_count    -- Количество котировок покупки (STRING)
-- offer_count  -- Количество котировок продажи (STRING)
-- bid          -- Котировки спроса (покупки) (TABLE)
-- offer        -- Котировки предложений (продажи) (TABLE)
   -- Таблицы «bid» и «offer» имеют следующую структуру:
     -- price     -- Цена покупки / продажи (STRING)
     -- quantity  -- Количество в лотах (STRING)
