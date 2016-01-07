-module(cal).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").

-record(meetings, {summary, location, day, month}).
-record(bday, {name, day, month}).
-record(date, {day, month, description,event}).

init() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
%    rpc:multicall([node()],cal,start,[mnesia]),
    mnesia:create_table(meetings, 
			    [{disc_copies, [node()]},
				{type, bag},
				{attributes, record_info(fields,meetings)}]),
    mnesia:create_table(bday,
			[{disc_copies, [node()]},
				{type, bag},
				{attributes,
					record_info(fields, bday)}]),
    mnesia:create_table(date,
			[{disc_copies, [node()]},
				{type, bag},
				{attributes,
					record_info(fields, date)}]).

%%inserting to the meeting table
insert_meetings(Summary, Loc, Day, Month) ->
    Fun = fun() ->
	mnesia:write(#meetings{
			summary = Summary,
			location = Loc,
			day = Day,
			month = Month})
	end,
    mnesia:transaction(Fun).

%% all meetings
read_all_meet() ->
    Fun = fun() ->
	qlc:eval(qlc:q([X || X <- mnesia:table(meetings)]))
        end,
    mnesia:transaction(Fun).

%% meetings on aspecific day
read_meet(Day, Month) ->
    Fun = fun()-> mnesia:match_object({meetings, '_', '_', Day, Month}) end,
    {atomic, Result} = mnesia:transaction(Fun),
    Result.

%% inserting to the bday table
insert_bdays(Name, Day, Month) ->
    Fun = fun() ->
	mnesia:write(#bday{
		name = Name,
		day = Day,
		month = Month})
	end,
    mnesia:transaction(Fun).

%% bday on on specific day
read_bday(Day, Month) ->
    Fun = fun() ->
	mnesia:match_object({bday, '_', '_', Day, Month}) end,
	{atomic, Res} = mnesia:transaction(Fun),
        Res.
read_all_bday() ->
    Fun = fun() ->
		qlc:eval(qlc:q([X || X <- mnesia:table(bday)]))
	end,
    mnesia:transaction(Fun).
%% insert meetings to the date table....
%date_table(Day, Month, Desc, Eve) ->

%%lect_date_table() ->
%%  Fun = fun() ->
%%lc:eval(qlc:q(
%	[X || X <- mnesia:table(date)]))
%end,
 %  mnesia:transaction(Fun).



%% join the meeting and bday on same date

join() ->
    Fun = fun() ->
	qlc:eval(qlc:q(
		[{X,Y}|| X <- mnesia:table(meetings),
		     Y <- mnesia:table(bday),
		  X#meetings.day =:= Y#bday.day andalso
		  X#meetings.month =:= Y#bday.month]))
         end,
    mnesia:transaction(Fun).

%% remove data from meetings table
remove_meeting(Day) ->
    Fun = fun() -> mnesia:delete({meetings, Day}) end,
    mnesia:transaction(Fun).

%% reset the table

reset_table() ->
    mnesia:clear_table(meetings),
    mnesia:clear_table(bday).

