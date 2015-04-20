%%%-------------------------------------------------------------------
%%% @author shepver
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Нояб. 2014 10:57
%%%-------------------------------------------------------------------
-module(protocol_handler).
-author("shepver").

%% API
-export([connect/0, login/1, send_condition/1]).



connect() ->
  gen_tcp:connect('127.0.0.1', 48260, [{active, once}, {packet, 0}, binary]).

login({Port, [Login, Imei]}) ->
  Data = egts:auth({1, [Login, Imei, 1]}),
  gen_tcp:send(Port, Data).




send_condition({Port, [Lon, Lat]}) ->
  gen_tcp:send(Port, Data)
.

