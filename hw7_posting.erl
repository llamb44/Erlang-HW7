%%Lindsay Lamy
%%HW7
%%c("C:\\Users\\Sweet\\OneDrive\\Documents\\College Stuff\\Actual Class Things\\fall2022\\Erlang\\hw7_posting.erl").

-module(hw7_posting).

posting(AuthPid)->
	receive
		{Pid, post, Text} when Pid =:= AuthPid -> io:format("~p~n", Text), posting(AuthPid)
	end.
	

