-module(aoc05).
-export([main/0, main/1]).

main() ->
    main("05.in").

main(FileName) ->
    {ok, DeviceA} = file:open(FileName, [read]),
    io:format("A: ~B~n", [d05a(DeviceA)]),
    {ok, DeviceB} = file:open(FileName, [read]),
    io:format("B: ~B~n", [d05b(DeviceB)]).

d05a(Device) ->
    {ok, Line} = file:read_line(Device),
    [_s | Seeds_str] = string:split(string:trim(Line, trailing), " ", all),
    Seeds = orddict:from_list(
              [{S1, S1} || S1 <- lists:map(fun list_to_integer/1, Seeds_str)]),
    a_read_line(Device, Seeds).


d05b(Device) ->
    {ok, Line} = file:read_line(Device),
    [_s | Seeds_str] = string:split(string:trim(Line, trailing), " ", all),
    Seeds = lists:map(
              fun(I) ->
                      From  = list_to_integer(lists:nth(I * 2 - 1, Seeds_str)),
                      Range = list_to_integer(lists:nth(I * 2, Seeds_str)),
                      {From, From + Range - 1, 0}
              end,
              lists:seq(1, length(Seeds_str) div 2)),
    b_read_line(Device, Seeds).


a_read_line(Device, Seeds) ->
    case file:read_line(Device) of
        eof ->
            lists:min([V || {_K, V} <- orddict:to_list(Seeds)]);
        {ok, Line} ->
            case {Line, string:rchr(Line, $:)} of
                {"\n", _Whatever} ->
                    a_read_line(Device, Seeds);
                {Line, 0} ->
                    [Dest, Src, Length]
                        = lists:map(
                            fun list_to_integer/1,
                            string:split(string:trim(Line, trailing), " ", all)
                          ),
                    NewSeeds = orddict:map(
                                 fun(K, V) ->
                                         case {K < Src, Src + Length < K} of
                                             {false, false} ->
                                                 K - Src + Dest;
                                             _At_least_one_true ->
                                                 V
                                         end
                                 end, Seeds),
                    a_read_line(Device, NewSeeds);
                _Colon ->
                         a_read_line(Device,
                                   orddict:from_list(
                                     [{V, V}
                                      || {_k, V} <- orddict:to_list(Seeds)]))
                 end
    end.


b_read_line(Device, Seeds) ->
    case file:read_line(Device) of
        eof ->
            lists:min([F + S || {F, _T, S} <- Seeds]);
        {ok, Line} ->
            case {Line, string:rchr(Line, $:)} of
                {"\n", _Whatever} ->
                    b_read_line(Device, Seeds);
                {Line, 0} ->
                    [Dest, Src, Length]
                        = lists:map(fun(S) -> list_to_integer(S) end,
                                    string:split(
                                      string:trim(Line, trailing),
                                      " ", all)),
                    Seeds1
                        = lists:map(
                            fun({From, To, Shift})->
                                    {From0, To0} = {Src, Src + Length - 1},
                                    case {To0 < From, From0 > To} of
                                        {false, false} ->
                                            From1 = lists:max([From0, From]),
                                            To1 = lists:min([To0, To]),
                                            RestFrom = case From < From0 of
                                                     true -> {From, From0 - 1, Shift};
                                                     false -> false
                                                 end,
                                            RestTo = case To0 < To of
                                                     true -> {To0 + 1, To, Shift};
                                                     false -> false
                                                 end,
                                            [{From1, To1, Dest - Src}, RestFrom, RestTo];
                                        _Same -> [{From, To, Shift}]
                                    end
                            end,
                            Seeds),
                    Seeds2 = [{From, To, Shift}
                              || List <- Seeds1, {From, To, Shift} <- List],
                    b_read_line(Device, Seeds2);
                _Colon ->
                         b_read_line(Device,
                                     [{From + Shift, To + Shift, 0}
                                      || {From, To, Shift} <- Seeds])
            end
    end.
