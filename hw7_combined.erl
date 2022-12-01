%%Lindsay Lamy
%%HW7
%%c("C:\\Users\\Sweet\\OneDrive\\Documents\\College Stuff\\Actual Class Things\\fall2022\\Erlang\\hw7_combined.erl").

-module(hw7_combined).

-export([start/0, signup/2,  post/3, stop/0]).

%LL: the client code
start() -> register(messageboard, spawn(fun() -> auth([]) end)).

signup(Name, Password) -> messageboard! {signup, Name, Password}.

post(Name, Password, Text) -> messageboard ! {post, Name, Password, Text}.

stop() -> stop_cmd ! messageboard.
	
	
	
%LL: the posting server's code, it still needs to be spawned
posting(AuthPid)->
	receive
		{Pid, post, Text} when Pid =:= AuthPid -> io:format("~p~n", Text), posting(AuthPid)
	end.