# $LOAD_PATH.unshift File.expand_path("./../../lib", __FILE__)
require 'minitest/autorun'
# require 'pry-rescue/minitest'
require 'main'

include GambleMarket

class PlayerTest < MiniTest::Test
  def setup
  end
end

class GoodTest < MiniTest::Test
end

class FactoryTest < MiniTest::Test
  def test_make_players
    players = Factory.make_players(Factory.read_csv(file_name))
    assert_equal 13, players.size
    assert_equal "나송현", players[0].info[:name]
    assert_equal 2, players[0].goods.size
  end

  def test_swap_deal_type
    deal_type = BUY
    assert_equal SELL, Factory.swap_deal_type(deal_type)
  end
end

class BoardTest < MiniTest::Test
  def setup
    @players = Factory.make_players(Factory.read_csv)
    Board.prepare
  end

  def test_transaction
    Board.wanted_to[BUY].transaction(@players[0], @players[1], @players[1].good(A), BUY)
    assert_equal 2, @players[0].good(A).quantity
    assert_equal 0, @players[1].good(A).quantity

    Board.wanted_to[SELL].transaction(@players[2], @players[3], @players[3].good(A), SELL)
    assert_equal 2, @players[2].good(A).quantity
    assert_equal 0, @players[3].good(A).quantity
  end
end
