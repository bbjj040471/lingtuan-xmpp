#erl -sname ecache@localhost -config ecache.config -noshell -pa ebin/ -pa deps/*/ebin/ -s ecache_run start & 
#erl -sname ecache@localhost -config ecache.config -pa ebin/ -pa deps/*/ebin/ -s ecache_run start
erl -noshell -name ecache@10.247.2.78 +K true +P 300000 -smp auto -env ERL_MAX_PORTS 60000 -config ecache.config -pa ebin/ -pa deps/*/ebin/ -s ecache_run start &
