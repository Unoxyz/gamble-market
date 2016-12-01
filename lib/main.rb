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

  def self.timestamp
    Time.now.strftime('%Y-%m-%d_%H-%M-%S')
  end

  Dir.mkdir("log") unless Dir.exist?("log/")
  filename = timestamp + "_app" + ".log"
  LOG = Logger.new('log/' + filename)
  LOG.level = Logger::DEBUG
  LOG.datetime_format = '%Y-%m-%d %H:%M:%S'


  Good = Struct.new(:type, :price, :dealer, :quantity)

  Statement = Struct.new(:board, :buyer, :seller, :good, :price) do
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

    def trade_by_turns
      players.pop.ask_deal(deal_type, good_type)
    end
  end

  module Factory
    def self.read_csv(file_name=ARGV[0])
      file_name = ARGV[0] || 'data/players.csv'
      CSV.read(file_name, :col_sep => "\t", headers: true, header_converters: :symbol, converters: :integer )
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

    def self.accumulated_goods
      { A => {
          wtp: Accumulator.new(read_csv[:wtp1]).by_desc,
          wta: Accumulator.new(read_csv[:wta1]).by_asc
        },
        B => {
          wtp: Accumulator.new(read_csv[:wtp2]).by_desc,
          wta: Accumulator.new(read_csv[:wta2]).by_asc
        }
      }
    end
  end

  class App
    @@csv = Factory.read_csv
    def self.run
      players = Factory.make_players(csv)
      players.extend Report
      Board.prepare

      LOG.info("Players start trading for goods A...")
      trade1 = TradeOrder.new(players, BUY, A)
      trade2 = TradeOrder.new(players, SELL, A)

      players.size.times do
        trade1.trade_by_turns
        trade2.trade_by_turns
      end
      LOG.info("Trade for A completed.\n" + "-" * 40)

      LOG.info("Players start trading for goods B...")
      trade1 = TradeOrder.new(players, BUY, B)
      trade2 = TradeOrder.new(players, SELL, B)

      players.size.times do
        trade1.trade_by_turns
        trade2.trade_by_turns
      end
      LOG.info("Trading for B completed.\n" + "-" * 40)
      players.export_csv
      # require 'pry'; binding.pry
    end

    def self.csv
      @@csv
    end
  end

  class Accumulator
    attr_reader :source, :wtp, :wta

    def initialize(source, order=:asc)
      @source = source
      @order = order
    end

    def by_desc
      accumulate(source.sort)
    end

    def by_asc
      accumulate(source.sort.reverse)
    end

    def accumulate(data)
      unique = data.uniq
      unique_count = data.uniq.map { |e| data.count(e) }

      unique_accumulated = unique_count.map.each_with_index { |item, index| unique_count[index..-1].inject(&:+) }

      { x: unique_accumulated.reverse, y: unique.reverse }
    end
  end

end
