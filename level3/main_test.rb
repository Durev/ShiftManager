#!/usr/bin/env ruby
gem 'minitest', '>= 5.0.0'
require 'minitest/autorun'
require_relative 'main'

class PlanningTest < Minitest::Test

  def setup
    @planning = Planning.new("test_data.json")
    @planning.export_payslip("test_output.json")
    output = File.open("test_output.json").read
    @payslip = JSON.parse(output)
  end

  def teardown
    File.delete("test_output.json")
  end

  def test_file_opening_and_parsing
    assert_equal 2, @planning.schedule["workers"].size
  end

  def test_shifts_count
    worker_1 = @planning.workers.detect { |worker| worker["id"] == 1 }
    assert_equal 4, worker_1["shifts"].size
  end

  def test_shift_price_calculation
    worker_1 = @planning.workers.detect { |worker| worker["id"] == 1 }
    assert_equal [540, 270, 270, 270], worker_1["shifts"]
  end

  def test_file_export
    assert_includes @payslip.keys, "workers"
  end

  def test_price_calculation
    worker_2 = @payslip["workers"].last
    assert_equal 378, worker_2["price"]
  end
end
