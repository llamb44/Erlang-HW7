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


        % name password
        % if signup message:
        % check if name is in the user list (one user per name like twitter) -
        % create cookie that consists of name++password using md5 -
        % add cookie to tuple(name, cookie) -
        % DONT STORE PASSWORD -
        % add tuple to user list -
        % respond with pid ok or pid duplicate
        % if post message:
        % check if name and password match the user list
        % if so the server sends (Pid, post, text) to posting server
        % posting server responds with pid ok or pid error
        
start() ->
    Swag = spawn(fun() -> auth([]) end)


%lindsey - client and posting server
%ian - making the authentication server 
%register yourself as message board
% The auth server receives messages 
% {Pid, signup, Name, Password} and {Pid, post, Name, Password, Text}.
% Upon receiving a signup message, the server creates a "cookie": an erlang:md5/1 hash 
% of the concatenation of the Name and the Password 
% (e.g., erlang:md5("Dmitry"++"mypassword")). 
% The server records the new user in the list of tuples {Name, Cookie}.