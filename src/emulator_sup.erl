%%%-------------------------------------------------------------------
%%% @author shepver
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Окт. 2014 11:05
%%%-------------------------------------------------------------------
-module(emulator_sup).
-author("shepver").
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).
-export([start_eqiupment/1]).

-define(SERVER, ?MODULE).
-include("equipment.hrl").

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
    MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
    [ChildSpec :: supervisor:child_spec()]
  }} |
  ignore |
  {error, Reason :: term()}).


init([disp]) ->
  {ok, {{one_for_one, 10, 100}, []}};

init([]) ->
  RestartStrategy = one_for_one,
  MaxRestarts = 10,
  MaxSecondsBetweenRestarts = 3600,

  SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

  Restart = permanent,
  Shutdown = 2000,
  Type = worker,

  Dispatcher = {dispatcher, {dispatcher, start_link, []},
    Restart, Shutdown, Type, [dispatcher]},
  SupervisorE =
    {equipment_sv, {supervisor, start_link, [{local, equipment_sv}, ?MODULE, [disp]]},
      permanent, infinity, supervisor, []},

  {ok, {SupFlags, [Dispatcher, SupervisorE]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

start_eqiupment(Equipment) ->
  {ok, _Pid} = supervisor:start_child(equipment_sv, {
    Equipment#equipment.id,
    {equipment, start_link, [Equipment]},
    transient,
    2000,
    worker,
    [equipment]
  }).



