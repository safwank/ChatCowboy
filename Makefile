# Feel free to use, reuse and abuse the code in this file.

all: app elixir

app: get-deps
	@./rebar compile

get-deps:
	@./rebar get-deps

clean:
	rm -rf __MAIN__
	rm -rf ebin

dist-clean: clean
	@./rebar clean
	rm -f erl_crash.dump

elixir: src/*
	rm -rf __MAIN__
	elixirc -pa 'deps/*/ebin' src/*.ex -o ebin
