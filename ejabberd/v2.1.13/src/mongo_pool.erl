-module(mongo_pool).

-behaviour(gen_server).

-include("ejabberd.hrl").

%% API
-export([start_link/1,checkout/1,checkin/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {pool,host,port,size,user,pwd,database}).

%% 清理连接的时间间隔
-define(CleanTime,1000*60*2).

%%%===================================================================
%%% API
%%%===================================================================
start_link({Name,Args}) ->
    gen_server:start_link({local, Name}, ?MODULE, [Args], []).

%% 获取一个连接
checkout(PoolName)->
	gen_server:call(PoolName,checkout).

%% 归还一个连接
checkin(PoolName,Conn) ->
	gen_server:cast(PoolName,{checkin,Conn}).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
%% [{host,"192.168.2.12"},{port,6379},{size,10}]
init([Args]) ->
	?INFO_MSG("pools:~p~n", [Args]),
	Conf = dict:from_list(Args),
	{ok,Host} = dict:find(host,Conf),
	{ok,Port} = dict:find(port,Conf),
	{ok,Size} = dict:find(size,Conf),
	{ok,User} = dict:find(user,Conf),
	{ok,Pwd} = dict:find(pwd,Conf),
	{ok,Database} = dict:find(database,Conf),
	Pool = build_pool(Size,Host,Port,User,Pwd,Database,queue:new()),									
    { ok , #state{host=Host,port=Port,size=Size,pool=Pool,user = User,pwd = Pwd,database = Database} , ?CleanTime }.

handle_call(checkout, _From, #state{host=H,port=P,pool=Pool,user = User,pwd = Pwd,database = Database}=State) ->
	case queue:out(Pool) of 
		{empty,_} ->
    		{reply, new_conn(H,P,User,Pwd,Database), State,?CleanTime};
		{{value,Conn},Pool2} ->
			Pool3 = queue:in(Conn,Pool2),
    		{reply, {ok,Conn}, State#state{pool=Pool3},?CleanTime} 
	end.

handle_cast({checkin,Conn}, #state{size=Size,pool=Pool}=State) ->
	Pool2 = case queue:len(Pool) >= Size of 
		true ->
			close_conn(Conn),
			Pool;
		false ->
			queue:in(Conn,Pool)
	end,	
    {noreply,State#state{pool=Pool2},?CleanTime};
handle_cast(stop, State) -> 
	{stop,normal,State}.


handle_info(timeout,#state{pool=Pool,size=Size}=State) ->
    {noreply, State#state{pool=free(Pool,Size)}, ?CleanTime};
handle_info(_Info, State) ->
    {noreply, State, ?CleanTime}.



terminate(_Reason, _State) -> ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

build_pool(N,H,P,User,Pwd,Database,Q) when N > 0 ->
	{ok,Conn} = new_conn(H,P,User,Pwd,Database),
	build_pool(N-1,H,P,User,Pwd,Database,queue:in(Conn,Q));
build_pool(0,_,_,_,_,_,Q) ->
	Q.

%% TODO 创建连接 
new_conn(H,P,User,Pwd,Database) ->
	Opts = [{host,H},
			{port,P},
			{timeout,1000}],
	?WARNING_MSG("mongo:connect~p",[{Database, User, Pwd,Opts}]),
	mongo:connect(Database, User, Pwd, unsafe, master, Opts).

close_conn(Conn) ->
	mongo:disconnect(Conn).

%% TODO 释放连接，如果连接数超过 Size
free(Pool,_Size) ->
	Pool.
