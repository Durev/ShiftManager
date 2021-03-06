require "json"
require "date"

class Planning

  STATUS_SALARIES = { "medic" => 270, "interne" => 126, "interim" => 480 }
  WEEKDAY_FEE = Hash.new(1) # Default fee for week days
  [6, 7].each { |day| WEEKDAY_FEE[day] = 2 } # Double fee for saturdays and sundays

  # The attributes readers are needed for the tests
  attr_reader :schedule, :shifts, :workers

  def initialize(input)
    data_file = File.open(input).read
    @schedule = JSON.parse(data_file)
    @shifts = schedule["shifts"]
    @workers = schedule["workers"]
  end

  def export_payslip(output = "output.json")
    get_all_shifts_prices
    payslip = {
                "workers" => get_salaries,
                "commission" => get_commission
              }
    File.open(output,"w") do |f|
      f.write(JSON.pretty_generate(payslip))
    end
  end

  private

    def get_all_shifts_prices
      @workers.each do |worker|
        worker["shifts"] = []
        @shifts
          .select { |shift| shift["user_id"] == worker["id"] }
          .each { |shift| calculate_shift_price(shift, worker) }
      end
    end

    def calculate_shift_price(shift, worker)
      day = Date.parse(shift["start_date"]).cwday
      status_rate = STATUS_SALARIES[worker["status"]]
      worker["shifts"].push(WEEKDAY_FEE[day] * status_rate)
    end


    def get_salaries
      @workers.collect do |worker|
        {
          "id" => worker["id"],
          "price" => worker["shifts"].sum
        }
      end
    end

    def get_commission
      interim_workers = @workers.select { |worker| worker["status"] == "interim" }
      interim_shifts = interim_workers
                        .inject([]) { |shifts, worker| shifts + worker["shifts"] }
                        .size
      all_shifts = @workers.inject([]) { |shifts, worker| shifts + worker["shifts"] }
      base_commission = all_shifts.sum * 0.05
      {
        "pdg_fee" => base_commission + interim_shifts*80.0,
        "interim_shifts" => interim_shifts
      }
    end
end

planning = Planning.new("data.json")
planning.export_payslip
