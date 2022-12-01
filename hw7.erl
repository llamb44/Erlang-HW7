-module(hw7).
-export([start/0]).

auth(Idlist) -> 
    receive
        {Pid, signup, Name, Password} ->
            if 
                keysearch(Name, 1, Idlist) -> 
                    Pid ! {Pid, duplicate};
            true ->
                Cookie = erlang:md5(Name++Password),
                UpdatedIdlist = [[Name, Cookie]|IdList], 
                Pid ! {Pid, ok},
                auth(UpdatedIdlist);

        {Pid, post, Name, Password, Text} ->
            Cookie = erlang:md5(Name++Password),
            if
                keysearch(Cookie, 2, Idlist) -> 
                    PostServer ! {Pid, post, Text}, %post server needs to be created
                    Pid ! {Pid, ok};
            true ->
                Pid ! {Pid, Error}
            auth(Idlist);
    end.
        
start() ->
    Pid = spawn(fun() -> auth([]) end)
    register(messageboard, Pid),

