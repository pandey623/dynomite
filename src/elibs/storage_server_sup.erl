%%%-------------------------------------------------------------------
%%% File:      untitled.erl
%%% @author    Cliff Moon <cliff@powerset.com> []
%%% @copyright 2008 Cliff Moon
%%% @doc  
%%%
%%% @end  
%%%
%%% @since 2008-06-27 by Cliff Moon
%%%-------------------------------------------------------------------
-module(storage_server_sup).
-author('cliff moon').

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

-include("config.hrl").

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================
%%--------------------------------------------------------------------
%% @spec start_link() -> {ok,Pid} | ignore | {error,Error}
%% @doc Starts the supervisor
%% @end 
%%--------------------------------------------------------------------
start_link(Config) ->
    supervisor:start_link(storage_server_sup, Config).

%%====================================================================
%% Supervisor callbacks
%%====================================================================
%%--------------------------------------------------------------------
%% @spec init(Args) -> {ok,  {SupFlags,  [ChildSpec]}} |
%%                     ignore                          |
%%                     {error, Reason}
%% @doc Whenever a supervisor is started using 
%% supervisor:start_link/[2,3], this function is called by the new process 
%% to find out about restart strategy, maximum restart frequency and child 
%% specifications.
%% @end 
%%--------------------------------------------------------------------
init(Config) ->
  Partitions = membership:partitions_for_node(node(), all),
  ChildSpecs = lists:map(fun(Part) ->
      Name = list_to_atom(lists:concat([storage_, Part])),
      DbKey = lists:concat([Config#config.directory, "/", Part]),
      {Name, {storage_server,start_link,[Config#config.storage_mod, DbKey, Name]}, permanent, 1000, worker, [storage_server]}
    end, Partitions),
    {ok,{{one_for_one,0,1}, ChildSpecs}}.

%%====================================================================
%% Internal functions
%%====================================================================