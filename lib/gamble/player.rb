module GambleMarket
  class Player
    attr_reader :info, :goods
    attr_accessor :cash
    def initialize(info, *goods)
      @info, @goods = info, goods
      @cash = 0
      @goods.each { |good| good.dealer = self }
    end

    def ask_deal(deal_type, good_type)
      LOG.info("#{self.name} ask deal to #{deal_type} #{good_type}")
      if deal_type == SELL and not in_stock?(good_type)
        LOG.info "Good #{good_type} is out of stock."
        return
      end
      board_type = Factory.swap_deal_type(deal_type)
      Board.wanted_to[board_type].trade(self, good_type)
    end

    def deal_succeed(deal_type, good_type)
      case deal_type
      when BUY
        good(good_type).quantity += 1
      when SELL
        good(good_type).quantity -= 1
      end
    end

    def in_stock?(good_type)
      good(good_type).quantity > 0
    end

    def good(type)
      goods.find { |e| e.type == type }
    end

    def name
      "#{self.info[:name]}[#{self.info[:id]}]"
    end
  end

  module Report
    def cashes(players)
      players.collect(&:cash)
    end

    def goods(attr)
      players.collet { |player| player.goods.collect(&attr) }
    end
  end
end
