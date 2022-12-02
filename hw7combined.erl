-module(hw7combined).
-export([start/0, signup/2,  post/3, stop/0]).

%LL: the client code
signup(Name, Password) -> messageboard ! {signup, Name, Password}.

post(Name, Password, Text) -> messageboard ! {post, Name, Password, Text}.

stop() ->  messageboard ! postServer ! stop_cmd.

auth(Idlist) -> 
    receive
        {Pid, signup, Name, Password} ->
            case lists:keysearch(Name, 1, Idlist) of
                {_,_} -> Pid ! {Pid, duplicate};
                false -> Cookie = erlang:md5(Name++Password),
                        UpdatedIdlist = [[Name, Cookie]|Idlist], 
                        Pid ! {Pid, ok},
                        auth(UpdatedIdlist)
            end;

        {Pid, post, Name, Password, Text} ->
            Cookie = erlang:md5(Name++Password),
            case lists:keysearch(Cookie, 2, Idlist) of
                {_,_} -> postServer ! {Pid, post, Text},
                         Pid ! {Pid, ok};
                false -> Pid ! {Pid, error},
            auth(Idlist)
            end;
        startPostServer -> MyPid= os:getpid(), register(postServer, spawn(fun() -> posting(MyPid) end));
        stop_cmd -> unregister(messageboard), erlang:exit("stopped")
    end.

posting(MyPid)->
	receive
		{Pid, post, Text} when Pid =:= MyPid -> io:format("~p~n", Text), posting(MyPid);
        stop_cmd -> unregister(postServer), erlang:exit("stopped")
	end.
        
start() ->
    %PostServer = spawn(fun() -> posting() end),
    Pid = spawn(fun() -> auth([]) end),
    register(messageboard, Pid),
    messageboard ! startPostServer.