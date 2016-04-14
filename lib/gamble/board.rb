module GambleMarket
  class Board
    @@wanted_to = {}
    attr_accessor :deal_type, :goods, :statements
    def initialize(deal_type, goods=[], statements=[])
      @deal_type, @goods, @statements = deal_type, goods, statements
    end

    def self.wanted_to
      @@wanted_to
    end

    def self.prepare
      @@wanted_to[BUY] = WantedToBuy.new(BUY)
      @@wanted_to[SELL] = WantedToSell.new(SELL)
    end

    def register_good(dealer, good_type)
      dealer_good = dealer.good(good_type)
      unless goods.include? dealer_good
        goods << dealer_good
        LOG.info("#{dealer.name} registered #{good_type} #{dealer.good(good_type).price[deal_type]} on #{deal_type}.")
      else
        LOG.info("#{dealer.name}'s #{good_type} is already registered .")
      end
    end

    def remove_good(good)
      goods.delete good
      LOG.info("#{good.dealer.name}'s #{good.type} is removed.")
    end

    def transaction(buyer, seller, good, deal_type)
      price = good.price[deal_type]
      buyer.cash -= price
      seller.cash += price
      statements << Statement.new(self, buyer, seller, good, price)
      buyer.deal_succeed(BUY, good.type)
      seller.deal_succeed(SELL, good.type)
      LOG.info(statements.last.to_s)
    end

    def check_deal_with_self

    end
  end

  # 팝니다 게시판
  class WantedToSell < Board
    def trade(player, good_type)
      good = suitable_good(player, good_type)
      buyer = player
      seller = good.dealer
      if not good.price.nil? and player.good(good_type).price[BUY] >= good.price[SELL] and buyer != seller
        transaction(buyer, seller, good, SELL)
        remove_good(good)
      else
        @@wanted_to[BUY].register_good(player, good_type)
      end
    end

    def suitable_good(player, good_type)
      result = goods.select { |good| good.type == good_type and good.dealer != player }.min_by { |good| good.price[SELL] }
      return result || Good.new
    end
  end

  # 삽니다 게시판
  class WantedToBuy < Board
    def trade(player, good_type)
      good = suitable_good(good_type)
      buyer = good.dealer
      seller = player
      if not good.price.nil? and player.good(good_type).price[SELL] <= good.price[BUY] and buyer != seller
        transaction(buyer, seller, good, BUY)
        remove_good(good)
      else
        @@wanted_to[SELL].register_good(player, good_type)
      end
    end

    def suitable_good(good_type)
      result = goods.select { |good| good.type == good_type }.max_by { |good| good.price[BUY] }
      return result || Good.new
    end
  end
end
