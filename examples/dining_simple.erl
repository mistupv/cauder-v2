-module(dining_simple).
-export([main/0, waiter/0, fork/1, philo/2]).

main() ->
    spawn(?MODULE, waiter, []).

spawn_forks(0, Dict) ->
    Dict;
spawn_forks(N, Dict) ->
    Pair = {N, spawn(?MODULE, fork, [free])},
    spawn_forks(N - 1, [Pair] ++ Dict).

spawn_philos(0, Dict, _) ->
    Dict;
spawn_philos(N, Dict, Pid) ->
    Pair = {spawn(?MODULE, philo, [Pid, N]), N},
    spawn_philos(N - 1, [Pair] ++ Dict, Pid).

waiter() ->
    ForkDict = spawn_forks(5, []),
    PhiloDict = spawn_philos(5, [], self()),
    waiter_1(ForkDict, PhiloDict).

waiter_1(ForkDict, PhiloDict) ->
    receive
        {eaten, PhiloPid} ->
            PhiloId = proplists:get_value(PhiloPid, PhiloDict),
            LeftForkId = PhiloId,
            RightForkId = 1 + (LeftForkId rem 5),
            LeftPid = proplists:get_value(LeftForkId, ForkDict),
            RightPid = proplists:get_value(RightForkId, ForkDict),
            set_state(LeftPid, free),
            set_state(RightPid, free);
        {hungry, PhiloPid} ->
            PhiloId = proplists:get_value(PhiloPid, PhiloDict),
            LeftForkId = PhiloId,
            RightForkId = 1 + (LeftForkId rem 5),
            LeftPid = proplists:get_value(LeftForkId, ForkDict),
            RightPid = proplists:get_value(RightForkId, ForkDict),
            LeftForkState = ask_state(LeftPid),
            RightForkState = ask_state(RightPid),
            case {LeftForkState, RightForkState} of
                {free, free} ->
                    set_state(LeftPid, used),
                    set_state(RightPid, used),
                    PhiloPid ! eat;
                _ ->
                    PhiloPid ! think
            end
    end,
    waiter_1(ForkDict, PhiloDict).

ask_state(Pid) ->
    Pid ! {get_state, self()},
    receive
        % Correct version
        {state, State, _} -> State
        % State -> State           % Buggy version
    end.

set_state(Pid, State) ->
    Pid ! {set_state, State, self()},
    receive
        % Correct version
        {been_set, _} -> ok
        % been_set -> ok    % Buggy version
    end.

philo(WaiterPid, PhiloId) ->
    think(PhiloId),
    request_until_eaten(WaiterPid, PhiloId),
    philo(WaiterPid, PhiloId).

think(PhiloId) ->
    io:fwrite("Philo " ++ integer_to_list(PhiloId) ++ " is thinking~n"),
    ThinkTime = rand:uniform(1000),
    timer:sleep(ThinkTime),
    ok.

eat(PhiloId) ->
    io:fwrite("Philo " ++ integer_to_list(PhiloId) ++ " has eaten~n"),
    timer:sleep(1000),
    ok.

request_until_eaten(WaiterPid, PhiloId) ->
    io:fwrite("Philo " ++ integer_to_list(PhiloId) ++ " is hungry~n"),
    WaiterPid ! {hungry, self()},
    receive
        think ->
            think(PhiloId),
            request_until_eaten(WaiterPid, PhiloId);
        eat ->
            eat(PhiloId),
            WaiterPid ! {eaten, self()}
    end.

fork(State) ->
    receive
        {get_state, WaiterPid} ->
            % Correct version
            WaiterPid ! {state, State, self()},
            % WaiterPid ! State,                % Buggy version
            fork(State);
        {set_state, NewState, WaiterPid} ->
            % Correct version
            WaiterPid ! {been_set, self()},
            % WaiterPid ! been_set,         % Buggy version
            fork(NewState)
    end.
