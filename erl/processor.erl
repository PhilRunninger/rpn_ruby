-module(processor).

-export([execute/2]).

%%% API

execute(String, Stack) ->
    loop(string:tokens(String, " "), Stack).

loop(Input, Stack) ->
    F = fun([], S) -> S;
           ([H|T], S) ->
                try rpn(H, S) of
                    NewS -> loop(T, NewS)
                catch _:Reason ->
                          io:format("**ERROR** while executing ~s -> ~p~n", [H, Reason]),
                          % erlang:display(erlang:get_stacktrace()),
                          S
                end
        end,
    F(Input, Stack).

%%% Internal functions

rpn(Operator, Stack) ->
    F = fun("+",     [X,Y|S]) -> [Y+X|S];
           ("-",     [X,Y|S]) -> [Y-X|S];
           ("*",     [X,Y|S]) -> [Y*X|S];
           ("/",     [X,Y|S]) -> [Y/X|S];
           ("div",   [X,Y|S]) -> [trunc(Y/X)|S];
           ("%",     [X,Y|S]) -> [Y rem X|S];
           ("**",    [X,Y|S]) -> [math:pow(Y,X)|S];
           ("chs",   [X  |S]) -> [-X|S];

           ("abs",   [X  |S]) -> [if X<0 -> -X; true -> X end|S];

           ("pi",         S ) -> [math:pi()|S];
           ("e",          S ) -> [math:exp(1)|S];
           ("phi",        S ) -> [(math:sqrt(5)+1)/2|S];
           ("i",          S ) -> [{0,1}|S];

           ("sin",   [X  |S]) -> [math:sin(X*math:pi()/180)|S];
           ("cos",   [X  |S]) -> [math:cos(X*math:pi()/180)|S];
           ("tan",   [X  |S]) -> [math:tan(X*math:pi()/180)|S];
           ("asin",  [X  |S]) -> [math:asin(X)*180/math:pi()|S];
           ("acos",  [X  |S]) -> [math:acos(X)*180/math:pi()|S];
           ("atan",  [X  |S]) -> [math:atan(X)*180/math:pi()|S];

           ("sinh",  [X  |S]) -> [math:sinh(X)|S];
           ("cosh",  [X  |S]) -> [math:cosh(X)|S];
           ("tanh",  [X  |S]) -> [math:tanh(X)|S];
           ("asinh", [X  |S]) -> [math:asinh(X)|S];
           ("acosh", [X  |S]) -> [math:acosh(X)|S];
           ("atanh", [X  |S]) -> [math:atanh(X)|S];

           ("sqrt",  [X  |S]) -> [math:sqrt(X)|S];
           ("\\",    [X  |S]) -> [1/X|S];
           ("exp",   [X  |S]) -> [math:exp(X)|S];
           ("log",   [X  |S]) -> [math:log(X)|S];
           ("log2",  [X  |S]) -> [math:log2(X)|S];
           ("log10", [X  |S]) -> [math:log10(X)|S];

           ("round", [X  |S]) -> [round(X)|S];
           ("trunc", [X  |S]) -> [trunc(X)|S];
           ("floor", [X  |S]) -> [round(math:floor(X))|S];
           ("ceil",  [X  |S]) -> [round(math:ceil(X))|S];

           ("copy",  [X  |S]) -> [X,X|S];
           ("del",   [_  |S]) -> S;
           ("cs",    _      ) -> [];
           ("xy",    [X,Y|S]) -> [Y,X|S];

           ("&",     [X,Y|S]) -> [X band Y|S];
           ("|",     [X,Y|S]) -> [X bor Y|S];
           ("^",     [X,Y|S]) -> [X bxor Y|S];
           ("~",     [X  |S]) -> [bnot X|S];
           ("<<",    [X,Y|S]) -> [Y bsl X|S];
           (">>",    [X,Y|S]) -> [Y bsr X|S];

           (Arg,          S ) -> [to_num(Arg)|S]
        end,
    F(Operator, Stack).

to_num(Arg) ->
    to_num(Arg, re:run(Arg,
                       "^(-?\\d+(\\.\\d+)?([Ee]-?\\d+)?),"
                        "(-?\\d+(\\.\\d+)?([Ee]-?\\d+)?)$",
                       [{capture,all,list}])).

to_num(_, {match,[_,Re,_,_,Im|_]}) -> {to_num(Re),to_num(Im)};
to_num(Arg, nomatch)               -> to_num(Arg, string:to_float(Arg));
to_num(Arg, {error,no_float})      -> list_to_integer(Arg);
to_num(_, {Float, _})              -> Float.
