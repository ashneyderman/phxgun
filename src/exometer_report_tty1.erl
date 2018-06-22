%% -------------------------------------------------------------------
%%
%% Copyright (c) 2014 Basho Technologies, Inc.  All Rights Reserved.
%%
%%   This Source Code Form is subject to the terms of the Mozilla Public
%%   License, v. 2.0. If a copy of the MPL was not distributed with this
%%   file, You can obtain one at http://mozilla.org/MPL/2.0/.
%%
%% -------------------------------------------------------------------

%% @doc Exometer reporter for lager backend
%%
%% This reporter emits messages to the lager logging backend,
%% at a reporting level chosen by the user (default: `notice').
%%
%% To change the reporting level, pass on the option `{level, Level}'.
%%
%% Example:
%% <pre lang="erlang">
%% Eshell V5.9.2  (abort with ^G)
%% 1&gt; exometer:start().
%% 17:41:14.078 [info] Application lager started on node nonode@nohost
%% ok
%% 17:41:14.125 [info] Starting reporters with []
%% 17:41:14.125 [info] Application exometer started on node nonode@nohost
%%
%% 2&gt; lager:set_loglevel(lager_console_backend,notice).
%% ok
%% 3&gt; exometer:new([c], counter).
%% ok
%% 4&gt; exometer:update([c], 2).
%% ok
%% 5&gt; exometer_report:add_reporter(
%%        exometer_report_lager,[{type_map,[{'_',integer}]}]).
%% ok
%% 6&gt; exometer_report:subscribe(exometer_report_lager,[c],[value],10000).
%% ok
%% 17:42:47.496 [notice] exometer_report_lager: c_value 1398008567:2 (integer)
%% 17:42:57.498 [notice] exometer_report_lager: c_value 1398008577:2 (integer)
%% 17:43:07.499 [notice] exometer_report_lager: c_value 1398008587:2 (integer)
%% 7&gt; exometer:update([c], 2).
%% ok
%% 17:43:17.501 [notice] exometer_report_lager: c_value 1398008597:4 (integer)
%% </pre>
%% @end

-module(exometer_report_tty1).

-compile([{parse_transform, lager_transform}]).
-behaviour(exometer_report).

-export(
   [
    exometer_init/1,
    exometer_info/2,
    exometer_cast/2,
    exometer_call/3,
    exometer_report/5,
    exometer_subscribe/5,
    exometer_unsubscribe/4,
    exometer_newentry/2,
    exometer_setopts/4,
    exometer_terminate/2
   ]).

%-include("exometer.hrl").
%-include("log.hrl").

-define(SERVER, ?MODULE).
%% calendar:datetime_to_gregorian_seconds({{1970,1,1},{0,0,0}}).
-define(UNIX_EPOCH, 62167219200).

-record(st, {stats_coll_ref = undefined, stats_coll_mod = undefined}).

%%%===================================================================
%%% exometer_report callback API
%%%===================================================================

exometer_init(Opts) ->
    %lager:log(debug, self(), "exometer_init: ~p", [Opts]),
    io:format("exometer_init: ~p", [Opts]),
    {ok, #st{
      stats_coll_ref = proplists:get_value(stats_coll_ref, Opts, undefined),
      stats_coll_mod = proplists:get_value(stats_coll_mod, Opts, undefined)
    }}.

exometer_subscribe(_Metric, _DataPoint, _Extra, _Interval, St) ->
    {ok, St}.

exometer_unsubscribe(_Metric, _DataPoint, _Extra, St) ->
    {ok, St}.

%% Invoked through the remote_exometer() function to
%% send out an update.
exometer_report(Metric, DataPoint, _Extra, Value, #st{stats_coll_ref = SRef, 
                                                      stats_coll_mod = Mod } = St)  ->
    lager:log(debug, self(), "exometer_report: ~p ~p ~p", [Metric, DataPoint, Value]),
    io:format("~p ~p ~p~n", [name(Metric, DataPoint), Value, SRef]),
    %Mod:record(name(Metric, DataPoint), Value, SRef),
    {ok, St}.

exometer_call(Unknown, From, St) ->
    {ok, St}.

exometer_cast(Unknown, St) ->
    {ok, St}.

exometer_info(Unknown, St) ->
    {ok, St}.

exometer_newentry(_Entry, St) ->
    {ok, St}.

exometer_setopts(_Metric, _Options, _Status, St) ->
    {ok, St}.

exometer_terminate(_, _) ->
    ignore.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% Add metric and datapoint within metric
name(Metric, DataPoint) ->
    metric_to_string(Metric) ++ "." ++ thing_to_list(DataPoint).

metric_to_string([Final]) ->
    thing_to_list(Final);
metric_to_string([H | T]) ->
    thing_to_list(H) ++ "." ++ metric_to_string(T).

thing_to_list(E) when is_atom(E) -> atom_to_list(E);
thing_to_list(E) when is_list(E) -> E;
thing_to_list(E) when is_integer(E) -> integer_to_list(E);
thing_to_list(E) when is_binary(E)  -> binary_to_list(E).


%% Add value, int or float, converted to list
value(V) when is_integer(V) -> integer_to_list(V);
value(V) when is_float(V)   -> io_lib:format("~f", [V]);
value(_) -> "0".

%log(Level, String) ->
%    lager:log(Level, self(), String).