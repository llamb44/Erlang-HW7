%%Lindsay Lamy, and Ian Demusis
%%HW7
%%c("C:\\Users\\Sweet\\OneDrive\\Documents\\College Stuff\\Actual Class Things\\fall2022\\Erlang\\hw7_combined.erl").

-module(hw7_combined).
-export([start/0, signup/2,  post/3, stop/0]).

%LL: the client code
start() ->
   register(messageboard, AuthPid= spawn (fun() -> auth([]) end)), register(postServer, spawn(fun() -> posting(AuthPid) end)), AuthPid.
	
signup(Name, Password) -> messageboard ! {self(), signup, Name, Password}.

post(Name, Password, Text) -> messageboard ! {self(), post, Name, Password, Text}.

stop() ->  messageboard ! postServer ! stop_cmd.

auth(Idlist) ->
    receive
        {Pid, signup, Name, Password} ->
			Cookie = erlang:md5(Name++Password),
            %case lists:keysearch(Name, 1, Idlist) of
			case lists:member(Cookie, Idlist) of
                true -> Pid ! {Pid, duplicate}, auth(Idlist);
                false ->
                        UpdatedIdlist = [[Name, Cookie]|Idlist], 
                        Pid ! {Pid, ok},
                        auth(UpdatedIdlist)
            end;

        {Pid, post, Name, Password, Text} ->
            Cookie = erlang:md5(Name++Password),
            %case lists:keysearch(Cookie, 2, Idlist) of
			case lists:member([Name, Cookie], Idlist) of
                true -> postServer ! {self(), post, Text},
                         Pid ! {Pid, ok},
						 auth(Idlist);
                false -> Pid ! {Pid, error}, auth(Idlist),
            auth(Idlist)
            end;
			
        stop_cmd -> unregister(messageboard), erlang:exit("stopped")
    end.

posting(AuthPid)->
	receive
		{Pid, post, Text} when Pid =:= AuthPid -> io:format("~p~n", [Text]), posting(AuthPid);
        stop_cmd -> unregister(postServer), erlang:exit("stopped")
	end.
        

	