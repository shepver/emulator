%% @author shepver

-module(equipment).
-behaviour(gen_server).
-include("equipment.hrl").
-export([start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).
-record(state, {equipment}).

start_link(Equipment) ->
  gen_server:start_link({local, Equipment#equipment.id}, ?MODULE, Equipment, []).


init(Equipment) ->
  error_logger:info_msg("Initial Equipment ~p .~n", [Equipment#equipment.id]),
  erlang:send_after(2000, self(), {send_condition, []}),
  {ok, #state{equipment = Equipment}}.


handle_call(_Request, _From, State) ->
  {reply, ignored, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

login(Login, Pass, Imei) ->
  case protocol_handler:connect() of
    {ok, Port} ->
      case protocol_handler:login({Port, [Login, Pass, Imei]}) of
        ok ->
%%           error_logger:error_msg("Login ok ~p", [Login]),
          {ok, Port};
        Error ->
          error_logger:error_msg("Login error ~p reason ~p ", [Login, Error]),
          {error, Error}
      end;
    Error ->
      error_logger:error_msg("Connect error ~p reason ~p ", [Login, Error]),
      {error, Error}
  end.

handle_info(run, #state{equipment = Equipment} = State) ->
  case login(Equipment#equipment.login, Equipment#equipment.pass, Equipment#equipment.imei) of
    {ok, Port} ->
%%       error_logger:error_msg("Login ok ~p", [Equipment#equipment.id]),
      erlang:send_after(2000 + crypto:rand_uniform(999, 3000), self(), {send_condition, []}),
      {noreply, State#state{equipment = Equipment#equipment{status = online, socket = Port}}};
    Error ->
      error_logger:error_msg("Error init equipment reason ~p", [Error]),
      erlang:send_after(10000, self(), run),
      {noreply, State}
  end;

handle_info({send_condition, Route}, #state{equipment = Equipment} = State) ->

  [Lon | [Lat | T]] = case Route of
                        [] -> Equipment#equipment.route;
                        Route -> Route
                      end,
  case protocol_handler:send_condition({Equipment#equipment.socket, [Lon, Lat]}) of
    ok ->
      erlang:send_after(2000, self(), {send_condition, T}),
      {noreply, State};
    Error ->
      error_logger:error_msg("Error send condition equipment reason ~p", [Error]),
      erlang:send_after(10000, self(), {relogin, Route}),
      {noreply, State}
  end;

handle_info({relogin, Route}, #state{equipment = Equipment} = State) ->
  gen_tcp:close(Equipment#equipment.socket),
  case login(Equipment#equipment.login, Equipment#equipment.pass, Equipment#equipment.imei) of
    {ok, Port} ->
      erlang:send_after(2000 + crypto:rand_uniform(999, 3000), self(), {send_condition, Route}),
      {noreply, State#state{equipment = Equipment#equipment{status = online, socket = Port}}};
    Error ->
      error_logger:error_msg("Error relogin equipment ~p reason: ~p ", [Equipment#equipment.login, Error]),
      erlang:send_after(10000, self(), {relogin, Route}),
      {noreply, State}
  end;


handle_info(login, #equipment{} = State) ->
  {noreply, State};


handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.



