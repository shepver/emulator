%%%-------------------------------------------------------------------
%%% @author shepver
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Окт. 2014 10:31
%%%-------------------------------------------------------------------
-module(utils).
-author("shepver").

%% API
-export([get_timestamp/0,convert_route/1]).

get_timestamp() ->
  {Ms, S, _} = os:timestamp(),
  Opttime = Ms * 1000000 + S,
  Opttime.
%% 11
convert_route(Route)->
  List = binary_to_list(Route),
  string:tokens(string:substr(List,12,string:len(List)-13)," ,")
  .
