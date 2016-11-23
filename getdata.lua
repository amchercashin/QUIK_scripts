Run = true;		-- ���� ����������� ������ �������

--TradeNums = {};	-- ������ ��� �������� ������� ���������� � ���� ������ (��� �������������� ������������)

-- ���������� ���������� QUIK � ������ ������� �������
function OnInit()
	-- �������, ��� ��������� ��� ������/���������� ���� CSV � ��� �� �����, ��� ��������� ������ ������
	CSV = io.open(getScriptPath().."/MyTrades.csv", "a+");
	-- ������ � ����� �����, �������� ����� �������
	local Position = CSV:seek("end",0);
	-- ���� ���� ��� ������
	if Position == 0 then
		-- ������� ������ � ����������� ��������
		local Header = "���� � �����;����� �. ������;���� �. ������;����� �. ������"
    for i = 1, 20 do
      Header = Header..";�������_�����_"..i..";�������_����_"..i
    end
    for i = 1, 20 do
      Header = Header..";�������_�����_"..i..";�������_����_"..i
    end
    Header = Header.."\n"
		-- ��������� ������ ���������� � ����
		CSV:write(Header);
		-- ��������� ��������� � �����
		CSV:flush();
	end;
end;

-- �������� ������� ������� (���� �������� ���, �������� ������)
function main()
	-- ����, �������������� ������ �������
	while Run do sleep(1000); end;
end;

-- ���������� ���������� QUIK � ������ ��������� �������
function OnStop()
	-- ��������� ����, ����� ���������� ���� while ������ main
	Run = false;
	-- ��������� �������� CSV-����
	CSV:close();
end;

--- ������� ���������� ���������� QUIK ��� ��������� ��������� ������� ���������
local my_class = "TQBR";
local my_sec = "ALRS";
Subscribe_Level_II_Quotes(my_class, my_sec);

function OnQuote(class, sec)
   --
    if class == my_class and sec == my_sec then
         ql2 = getQuoteLevel2(class, sec);
      -- ������������ ������ ������� � ���� ������
         QuoteStr = os.date()..";"
         QuoteStr = QuoteStr..tonumber(getParamEx(class,  sec, "QTY").param_value)..";"
         QuoteStr = QuoteStr..tonumber(getParamEx(class,  sec, "LAST").param_value)..";"
         QuoteStr = QuoteStr..getParamEx(class,  sec, "TIME").param_value..";"
         for i = 1, tonumber(ql2.bid_count), 1 do
            if ql2.bid[i].quantity ~= nil then   -- �� ��������� ����� ����� ������������� ������
               QuoteStr = QuoteStr..tostring(tonumber(ql2.bid[i].quantity))..";"..tostring(tonumber(ql2.bid[i].price))..";";
            else
               QuoteStr = QuoteStr.."0;"..tostring(tonumber(ql2.bid[i].price))..";";
            end;
         end;
         for i = 1, tonumber(ql2.offer_count), 1 do
            if ql2.offer[i].quantity ~= nil then   -- �� ��������� ����� ����� ������������� ������
               QuoteStr = QuoteStr..tostring(-tonumber(ql2.offer[i].quantity))..";"..tostring(-tonumber(ql2.offer[i].price));
            else
               QuoteStr = QuoteStr.."0;"..tostring(tonumber(ql2.offer[i].price));
            end;
            if i < tonumber(ql2.offer_count) then QuoteStr = QuoteStr..";" end
         end;
   -- ���������� ������ � ����
        QuoteStr = QuoteStr.."\n"
        --message(QuoteStr)
	      CSV:write(QuoteStr);
   -- ��������� ��������� � �����
	      CSV:flush();
    end;
end;



-- � ���������� ��� ������ ���������� ������� �� ����������� RTS-6.15 � ���������� QuoteStr ����� ������, ����:
   -- "15;86130;17;86120;16;86110;22;86100;16;86090;24;86080;26;86070;29;86060;97;86050;51;86040;99;86030;88;86020;143;86010;140;86000;15;85990;49;85980;58;85970;28;85960;49;85950;36;85940;71;85930;115;85920;95;85910;25;85900;5;85890;13;85880;62;85870;3;85860;36;85850;26;85840;11;85830;9;85820;99;85810;86;85800;41;85790;24;85780;2;85770;36;85760;162;85750;22;85740;44;85730;76;85720;229;85710;121;85700;5;85690;5;85680;2;85670;10;85660;148;85650;119;85640;12;86150;19;86160;26;86170;32;86180;71;86190;49;86200;26;86210;20;86220;91;86230;57;86240;47;86250;25;86260;34;86270;41;86280;21;86290;66;86300;36;86310;57;86320;50;86330;34;86340;38;86350;22;86360;17;86370;15;86380;18;86390;13;86400;3;86410;34;86420;29;86430;80;86440;26;86450;68;86460;226;86470;371;86480;30;86490;64;86500;99;86510;11;86520;2;86530;23;86540;9;86550;3;86560;52;86570;23;86580;25;86590;73;86600;17;86610;88;86620;52;86630;150;86640"
   -- ����� ������ ������, � �����������, ���������� � C# � ��������� �� ��������

-- ������� getQuoteLevel2() ��������� 2 ���������: ��� ������ � ��� ������, � ���������� �������, ������� ����� ��������� ����:
-- bid_count    -- ���������� ��������� ������� (STRING)
-- offer_count  -- ���������� ��������� ������� (STRING)
-- bid          -- ��������� ������ (�������) (TABLE)
-- offer        -- ��������� ����������� (�������) (TABLE)
   -- ������� �bid� � �offer� ����� ��������� ���������:
     -- price     -- ���� ������� / ������� (STRING)
     -- quantity  -- ���������� � ����� (STRING)
