#■イスカンダルのトーフ屋ゲーム■ (外部仕様より再現)
#Copyright (C) 1978-2013 by N.Tsuda
#背景: あなたはイスカンダル星で遭難し、帰りの費用を稼ぐためにトーフをなるべくたくさん売ってお金を稼がなければならない。
#最初に所持金1000円が与えられる。
#30000円儲けることができれば、めでたくイスカンダルから脱出することができる。
#トーフは製造に一個あたり10円かかり、一個あたり12円で売ることができる。
#トーフは晴れの日は100個、曇りの日は50個、雨の日は10個売れる。
#売れなかった分は損失となる。
#あなたは天気予報を見て、明日いくつのトーフを製造するかを決めねばならない。
class Iscandar
	COST = 10
	PRICE = 12
	WEATHER = {fine: "Fine", cloudy: "Cloudy", rainy: "Rainy"}
	RATE = {fine: 100, cloudy: 50, rainy: 10}
	RED = "\e[31m"
	GRN = "\e[32m"
	SO = "\e[m"

	def initialize
		@forecast = {}
		@total = 1000

		self.show_comment
		puts
		puts "Now you have #{GRN}#{@total}#{SO} yen. "
	end

	def show_comment
		file = File.basename(__FILE__)
		puts file
		puts (`cat #{file} | grep "^#"`).delete("#")
	end

	def calc_probab
		probab = {}
		probab[:fine] = rand(100)
		probab[:cloudy]= rand(100 - probab[:fine])
		probab[:rainy] = 100 - probab[:fine] - probab[:cloudy]
		return probab
	end

	def wait_for_input
		loop do
			print "Enter the quantity of Tofu: "
			input = gets
			if  /[0-9]+/ =~ input.to_s and input.to_i > 0 then
				puts "Tofu you made: #{input}"
				return input.to_i
				break
			elsif input == "exit\n" then
				puts "You gained #{@total} yen so far."
				puts "Good Bye!"
				exit
			else
				puts "The input is invalid. Enter again."
			end
		end
	end

	def weather_forecast
		puts
		puts "-" * 80
		puts "Weather Forecast"
		print "Probability: "
		@forecast = calc_probab
		print "Fine: #{@forecast[:fine]}%, Cloudy: #{@forecast[:cloudy]}%, Rainy: #{@forecast[:rainy]}%.\n"
		puts "-" * 80
		puts
	end

	def next_day(sell: 100)
		lost = 0
		tmp2 = {}
		tmp1 = calc_probab
		tmp1.each_pair {|i,j| tmp2[i] = j * @forecast[i]}
		nextday = tmp2.sort {|a, b| b[1] <=> a[1]}
		result = nextday[0][0] #extract the result
		sleep 1

		puts "It's #{RED}#{WEATHER[result]}!#{SO}"

		if sell > RATE[result] then
			lost = sell - RATE[result]
			sell -= lost
		end
		@total = @total + (sell * PRICE) - (lost * COST)

		puts "You sold #{GRN}#{sell}#{SO} Tofu and totaled #{GRN}#{sell * PRICE}#{SO} yen."
		puts "You lost #{RED}#{lost}#{SO} Tofu and lost #{RED}#{lost * COST}#{SO} yen."
		puts "Now you have #{GRN}#{@total}#{SO} yen. "
		puts

		if @total < 0 then
			puts "...Your capital has been shortened. Bad ending. Bye."
			exit
		end
	end

	def run
		while @total < 30000
			self.weather_forecast
			self.next_day(sell: self.wait_for_input)
		end

		puts "Congratulation! You gained #{@total} yen. Bye."
		exit
	end
end

obj = Iscandar.new
	obj.run
