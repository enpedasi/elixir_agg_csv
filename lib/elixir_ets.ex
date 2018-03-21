defmodule ElixirEts do
	def run( filename ) do
	
  start = Timex.now
    parent = self()
  
  result = 
  	filename
  	|> File.stream!

  	# データクレンジング
  	|> Flow.from_enumerable()
  	|> Flow.map( &( String.replace( &1, ",",    "\t" )   	# ①CSV→TSV
  	                |> String.replace( "\r\n", "\n" )    	# ②CRLF→LF
  	                |> String.replace(  "\"",   ""  ) ) )  # ③ダブルクォート外し
  	# 集計
  	|> Flow.map( &( &1 |> String.split( "\t" ) ) )    	# ④タブで分割
  	|> Flow.map( &Enum.at( &1, 2 - 1 ) )      	# ⑤2番目の項目を抽出
  	|> Flow.partition
      |> Flow.reduce(fn -> :ets.new(:words, []) end, fn word, ets -> # ETS
        :ets.update_counter(ets, word, {2, 1}, {word, 0})
        ets
      end)
      |> Flow.map_state(fn ets ->         # ETS
        :ets.give_away(ets, parent, [])   # オーナーを変える
        [ets]
      end)
      |> Enum.to_list
      |> Enum.flat_map( &(:ets.tab2list(&1)) )
  	|> Enum.sort( &( elem( &1, 1 ) > elem( &2, 1 ) ) )    # ⑦多い順でソート

  IO.inspect( result )

  finish = Timex.now
  IO.puts( start )
  IO.puts( finish )
  minutes = Timex.diff( finish, start, :minutes )
  seconds = Timex.diff( finish, start, :seconds )           - minutes * 60
  millis = Timex.diff( finish, start, :milliseconds ) - minutes * 60 * 1000        - seconds * 1000
  millis_pad = millis |> Integer.to_string |> String.pad_leading( 3, "0" )
  # IO.puts( "#{ minutes }m#{ seconds }.#{ millis_pad }s" )
  
  # save result to file
  file_w = File.open! "results_elixir.csv", [:write]
  result
  |> Enum.map(fn tpl -> tpl |> Tuple.to_list |> Enum.join(",") end)
  |> Enum.map(fn rec -> IO.puts(file_w, rec) end)
  File.close file_w
  {result |> Enum.take(10) , "#{ minutes }m#{ seconds }.#{ millis_pad }s"}
	end
end
