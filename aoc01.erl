-module(aoc01).
-export([main/0, main/1]).

main() ->
    main("01.in").

main(FileName) ->
    {ok, DeviceA} = file:open(FileName, [read]),
    io:format("A: ~B~n", [calibrate_a(DeviceA, 0)]),
    {ok, DeviceB} = file:open(FileName, [read]),
    io:format("B: ~B~n", [calibrate_b(DeviceB, 0)]).

calibrate_a(Device, Sum) ->
    case io:fread(Device, "", "~s") of
        {ok, [String]} ->
            Digits = lists:map(fun({D, _Rest}) -> D end,
                               [string:to_integer([C])
                                || C <- String, [C] =< "9", [C] > "0"]),
            calibrate_a(Device,
                        Sum + lists:nth(1, Digits) * 10 + lists:last(Digits));
        eof -> Sum
    end.

calibrate_b(Device, Sum) ->
    Values = maps:merge(#{"one" => 1, "two" => 2, "three" => 3, "four" => 4,
                          "five" => 5, "six" => 6, "seven" => 7, "eight" => 8,
                          "nine" => 9},
                        maps:from_list(
                            lists:map(fun(I) ->
                                              {integer_to_list(I), I}
                                      end,
                                      lists:seq(1, 9)))),
    calibrate_b_(Device, Values, Sum).

calibrate_b_(Device, Values, Sum) ->
    case io:fread(Device, "", "~s") of
        {ok, [String]} ->
            {_, Left} = lists:min(lists:filter(
                     fun({Pos, _Val}) -> Pos > 0 end,
                     [{string:str(String, Key), maps:get(Key, Values)}
                      || Key <- maps:keys(Values)])),
            {_, Right} = lists:max(lists:filter(
                     fun({Pos, _Val}) -> Pos > 0 end,
                     [{string:rstr(String, Key), maps:get(Key, Values)}
                      || Key <- maps:keys(Values)])),
            Add = Left * 10 + Right,
            calibrate_b_(Device, Values, Sum + Add);
        eof -> Sum
    end.
