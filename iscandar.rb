#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

##■イスカンダルのトーフ屋ゲーム■ (外部仕様より再現)
##Copyright (C) 1978-2013 by N.Tsuda
##Reference: http://vivi.dyndns.org/tofu/tofu.html
##背景: あなたはイスカンダル星で遭難し、帰りの費用を稼ぐためにトーフをなるべくたくさん売ってお金を稼がなければならない。
##最初に所持金1000円が与えられる。
##30000円儲けることができれば、めでたくイスカンダルから脱出することができる。
##トーフは製造に一個あたり10円かかり、一個あたり12円で売ることができる。
##トーフは晴れの日は100個、曇りの日は50個、雨の日は10個売れる。
##売れなかった分は損失となる。
##あなたは天気予報を見て、明日いくつのトーフを製造するかを決めねばならない。
##
##A Tofu vendor surviving in Iscandar
##Copyright (C) 1978-2013 by N.Tsuda
##Reference: http://vivi.dyndns.org/tofu/tofu.html
##Background: You are a castaway in planet Iscandar in outer space, and you have to gain money by making and selling Tofu in order to go back to your mother planet.
##Initially you have 1,000 yen. The goal is to gain 30,000 yen for your traveling fee.
##One Tofu costs 10 yen for production, and the unit price is 12 yen.
##The sales of Tofu depends on weather: you can sell 100 Tofu on a fine day, 50 on a cloudy day, and 10 on a rainy day.
##Watch weather forecast and determine the quantity of Tofu you are going to make.

class Iscandar
  COST    = 10
  PRICE   = 12
  RATE    = {
    fine:   100,
    cloudy:  50,
    rainy:   10
  }
  RED = "\e[31m"
  GRN = "\e[32m"
  SO  = "\e[m"

  def initialize
    @forecast = {}
    @total    = 1000

    self.show_comment
  end

  def show_comment
    file = File.basename(__FILE__)
    puts (`cat #{file} | grep "^##"`).delete("##")
  end

  def calc_probab
    probab          = {}
    probab[:fine]   = rand(100)
    probab[:cloudy] = rand(100 - probab[:fine])
    probab[:rainy]  = 100      - probab[:fine] - probab[:cloudy]
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
    lost    = 0

    # Do not use something like 'tmp' and 'result' that give no info to coders (including you!).
    # The name of variables should contain the key information to understand (should be like a very short comment).
    # So for example, use 'probablility' and 'prob_of_whether' that give information to understand.
    # See 'The Art of Readable Code' for details.

    #Revised based on the suggestion above.
    lost              = 0
    weighted_weather  = {}
    next_weather      = calc_probab
    next_weather.each_pair {|i,j| weighted_weather[i] = j * @forecast[i]}
    sorted_weather    = weighted_weather.sort {|a, b| b[1] <=> a[1]}
    actual_weather    = sorted_weather.first.first #extract the result
    sleep 1

    puts "It's #{RED}#{actual_weather}!#{SO}"
    sleep 0.5
    if sell > RATE[actual_weather] then
      lost = sell - RATE[actual_weather]
      sell -= lost
    end
    @total = @total + (sell * PRICE) - (lost * COST)

    puts "You sold #{GRN}#{sell}#{SO} Tofu and gained #{GRN}#{sell * PRICE}#{SO} yen."
    puts "You lost #{RED}#{lost}#{SO} Tofu and lost #{RED}#{lost * COST}#{SO} yen."
    sleep 0.5
    puts "Now you have #{GRN}#{@total}#{SO} yen. "
    puts

    if @total < 0 then
      puts "...Your capital has been shortened. Bad ending. Bye."
      exit
    end
  end

  def run
    puts
    puts "Now you have #{GRN}#{@total}#{SO} yen. "
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
