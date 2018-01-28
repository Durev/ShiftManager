require "json"

class Planning

  STATUS_SALARIES = { "medic" => 270, "interne" => 126 }

  # The methods to read the attributes are used in the tests
  attr_reader :schedule, :shifts

  def initialize(input)
    data_file = File.open(input).read
    @schedule = JSON.parse(data_file)
    @shifts = @schedule["shifts"]
  end

  def export_payslip(output = "output.json")
    payslip = { "workers" => count_prices }
    File.open(output,"w") do |f|
      f.write(JSON.pretty_generate(payslip))
    end
  end

  private

    def count_prices
      @schedule["workers"]
      .collect do |worker|
        worker["shifts_count"] = @shifts.count{|shift| shift["user_id"] == worker["id"]}
        {
          "id" => worker["id"],
          "price" => STATUS_SALARIES[worker["status"]]*worker["shifts_count"]
        }
      end
    end
end

planning = Planning.new("data.json")
planning.export_payslip
