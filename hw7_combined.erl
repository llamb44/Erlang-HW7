-module(hw7_combined).
-export([start/0, signup/2,  post/3, stop/0]).

%LL: the client code
signup(Name, Password) -> messageboard! {signup, Name, Password}.

post(Name, Password, Text) -> messageboard ! {post, Name, Password, Text}.

stop() -> stop_cmd ! messageboard.

auth(Idlist, PostServer) -> 
    receive
        {Pid, signup, Name, Password} ->
            if 
                keysearch(Name, 1, Idlist) -> 
                    Pid ! {Pid, duplicate};
            true ->
                Cookie = erlang:md5(Name++Password),
                UpdatedIdlist = [[Name, Cookie]|Idlist], 
                Pid ! {Pid, ok},
                auth(UpdatedIdlist, PostServer)
            end;

        {Pid, post, Name, Password, Text} ->
            Cookie = erlang:md5(Name++Password),
            if
                keysearch(Cookie, 2, Idlist) -> 
                    PostServer ! {Pid, post, Text}, %post server needs to be created
                    Pid ! {Pid, ok};
            true ->
                Pid ! {Pid, error}
            end,
        auth(Idlist, PostServer)
    end.

posting()->
	receive
		{Pid, post, Text} when Pid =:= messageboard -> io:format("~p~n", Text), posting()
	end.
        
start() ->
    PostServer = spawn(fun() -> posting() end),
    Pid = spawn(fun() -> auth([], PostServer) end),
    register(messageboard, Pid).

