require 'csv'
require 'logger'

require 'gamble/player'
require 'gamble/board'

module GambleMarket
  # good_type
  A, B = 'A', 'B'
  # deal_type
  BUY, SELL = 'Buy', 'Sell'

  WTA = 'willingness to accept'
  WTP = 'willingness to pay'

  Dir.mkdir("log") unless Dir.exist?("log/")
  LOG = Logger.new('log/app.log', 'daily')
  LOG.level = Logger::DEBUG
  LOG.datetime_format = '%Y-%m-%d %H:%M:%S'


  Good = Struct.new(:type, :price, :dealer, :quantity)

  Statement  = Struct.new(:board, :buyer, :seller, :good, :price) do
    def to_s
      "#{board.deal_type} B:#{buyer.name} S:#{seller.name} #{good.type} #{price}"
    end
  end

  class TradeOrder
    attr_reader :players, :deal_type, :good_type
    def initialize(players, deal_type, good_type)
      @players = players.shuffle
      @deal_type, @good_type = deal_type, good_type
    end

    def trade_loop
      players.each { |player| player.ask_deal(deal_type, good_type) }
    end

    def trade_step
      players.pop.ask_deal(deal_type, good_type)
    end
  end

  module Factory
    def self.read_csv(file_name=ARGV[0])
      if file_name.nil?
        puts "please give me a csv_filename"
        exit
      end
      CSV.read(file_name, headers: true, header_converters: :symbol, converters: :integer)
      # Player = Struct.new(:id, :name, :student_id, :q1str, :q1, :wtp1, :wtp2, :wta1, :wta2, :cash)
    end

    def self.make_players(rows)
      rows.collect do |row|
        good_a = Good.new(A, {BUY => row[:wtp1], SELL => row[:wta1]}, nil, 1)
        good_b = Good.new(B, {BUY => row[:wtp2], SELL => row[:wta2]}, nil, 1)
        Player.new(row, good_a, good_b)
      end
    end

    def self.swap_deal_type(deal_type)
      deal_type == BUY ? SELL : BUY
    end
  end

  module App
    def self.run
      players = Factory.make_players(Factory.read_csv)
      Board.prepare
      trade1 = TradeOrder.new(players, BUY, A)
      trade2 = TradeOrder.new(players, SELL, A)
      LOG.info("Players start trading...")
      players.size.times do
        trade1.trade_step
        trade2.trade_step
      end
      LOG.info("Trading completed.\n" + "-" * 40)
    end
  end
end
