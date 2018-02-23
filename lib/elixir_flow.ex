defmodule ElixirFlow do
	def run( filename ) do
		start = Timex.now

		result = 
			filename
			|> File.stream!

			# データクレンジング
			|> Flow.from_enumerable()
			|> Flow.map( &( String.replace( &1, ",",    "\t" ) 			# ①CSV→TSV
			                |> String.replace( "\r\n", "\n" )		  	# ②CRLF→LF
			                |> String.replace(  "\"",   ""  ) ) )		# ③ダブルクォート外し
			# 集計
			|> Flow.map( &( &1 |> String.split( "\t" ) ) )					# ④タブで分割
			|> Flow.map( &Enum.at( &1, 2 - 1 ) )							# ⑤2番目の項目を抽出
			|> Flow.partition

			|> Flow.reduce( 
				fn -> %{} end, fn( name, acc ) 					# ⑥同値の出現数を集計
				-> Map.update( acc, name, 1, &( &1 + 1 ) ) end )
			|> Enum.sort( &( elem( &1, 1 ) > elem( &2, 1 ) ) )				# ⑦多い順でソート

		IO.inspect( result )

		finish = Timex.now
		IO.puts( start )
		IO.puts( finish )
		minutes = Timex.diff( finish, start, :minutes )
		seconds = Timex.diff( finish, start, :seconds )           - minutes * 60
		millis = Timex.diff( finish, start, :milliseconds ) - minutes * 60 * 1000        - seconds * 1000
		millis_pad = millis |> Integer.to_string |> String.pad_leading( 3, "0" )
		# IO.puts( "#{ minutes }m#{ seconds }.#{ millis_pad }s" )
		{result |> Enum.take(10) , "#{ minutes }m#{ seconds }.#{ millis_pad }s"}
	end
end

defmodule ElixirFlowOrg do
	def run( filename ) do
		start = Timex.now

		result = 
			filename
			|> File.stream!

			# データクレンジング
			|> Flow.from_enumerable()
			|> Flow.map( &( String.replace( &1, ",",    "\t" ) ) )			# ①CSV→TSV
			|> Flow.map( &( String.replace( &1, "\r\n", "\n" ) ) )			# ②CRLF→LF
			|> Flow.map( &( String.replace( &1, "\"",   ""   ) ) )			# ③ダブルクォート外し

			# 集計
			|> Flow.map( &( &1 |> String.split( "\t" ) ) )					# ④タブで分割
			|> Flow.map( &Enum.at( &1, 2 - 1 ) )							# ⑤2番目の項目を抽出
			|> Flow.partition

			|> Flow.reduce( 
				fn -> %{} end, fn( name, acc ) 					# ⑥同値の出現数を集計
				-> Map.update( acc, name, 1, &( &1 + 1 ) ) end )
			|> Enum.sort( &( elem( &1, 1 ) > elem( &2, 1 ) ) )				# ⑦多い順でソート

		IO.inspect( result )

		finish = Timex.now
		IO.puts( start )
		IO.puts( finish )
		minutes = Timex.diff( finish, start, :minutes )
		seconds = Timex.diff( finish, start, :seconds )           - minutes * 60
		millis = Timex.diff( finish, start, :milliseconds ) - minutes * 60 * 1000        - seconds * 1000
		millis_pad = millis |> Integer.to_string |> String.pad_leading( 3, "0" )
		# IO.puts( "#{ minutes }m#{ seconds }.#{ millis_pad }s" )
		{result |> Enum.take(10) , "#{ minutes }m#{ seconds }.#{ millis_pad }s"}
	end
end
