#■イスカンダルのトーフ屋ゲーム■ (外部仕様より再現)

#背景: あなたはイスカンダル星で遭難し、帰りの費用を稼ぐためにトーフをなるべくたくさん売ってお金を稼がなければならない。
#最初に所持金1000円が与えられる。
#30000円儲けることができれば、めでたくイスカンダルから脱出することができる。
#トーフは製造に一個あたり10円かかり、一個あたり12円で売ることができる。
#トーフは晴れの日は100個、曇りの日は50個、雨の日は10個売れる。
#売れなかった分は損失となる。
#あなたは天気予報を見て、明日いくつのトーフを製造するかを決めねばならない。
class Iscandar
	private show_comment
	attr_accessor :total, :lost
	def initialize
		COST = 10
		PRICE = 12
		RED = "\e[31m"
		GRN = "\e[32m"
		SO = "\e[m"
		@input = []
		@total = 1000
		@sell = 0
		@lost = 0

		show_comment
		puts "Now you have #{GRN}#{@total}#{SO} yen. "
	end

	def show_comment
		file = File.basename(__FILE__)
		puts file
		puts (`cat #{file} | grep "^#"`).delete("#")
	end

	def calc
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
				@input = input.to_i
				break
			elsif input == "exit\n" then
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
		infer = calc
		print "Fine: #{infer[:fine]}%, Cloudy: #{infer[:cloudy]}%, Rainy: #{infer[:rainy]}%.\n"
		puts "-" * 80
	end

	def next_day
		nextday = calc
		result = {}
		nextday.each_pair {|i,j| result[i] = j * infer[i]}
		final = result.sort {|a, b| b[1] <=> a[1]}
		p final
		sleep 1
		case final[0][0]
		when :fine
			puts "It's #{RED}Fine!#{SO}"
			if sell > 100 then
				lost = sell - 100
				sell -= lost
			end
			total = total + (sell * PRICE) - (lost * COST)
		when :cloudy
			puts "It's #{RED}Cloudy!#{SO}"
			if sell > 50 then
				lost = sell - 50
				sell -= lost
			end
			total = total + (sell * PRICE) - (lost * COST)
		when :rainy
			puts "It's #{RED}Raining!#{SO}"
			if sell > 10 then
				lost = sell - 10
				sell -= lost
			end
			lost = sell - 10 if sell > 10
			total = total + (sell * PRICE) - (lost * COST)
		end
		puts "You sold #{GRN}#{sell}#{SO} Tofu and totaled #{GRN}#{sell * PRICE}#{SO} yen."
		puts "You lost #{RED}#{lost}#{SO} Tofu and lost #{RED}#{lost * COST}#{SO} yen."
		puts "Now you have #{GRN}#{total}#{SO} yen. "
		puts
	end
end

obj = Iscandar.new

while obj.total < 30000
	obj.lost = 0
	obj.weather_forecast
	obj.wait_for_input
	obj.next_day
end

puts "Congratulation! You totaled #{} yen. Bye."