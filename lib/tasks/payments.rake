namespace :payments do
  desc "Mark past-due pending charges as overdue (Buildium-style sweep)"
  task mark_overdue: :environment do
    count = Payment.mark_overdue!
    puts "Marked #{count} charge(s) overdue."
  end

  desc "Generate monthly condo fees for all units, e.g. rake payments:generate_monthly[500]"
  task :generate_monthly, [:amount] => :environment do |_, args|
    amount = (args[:amount] || 500).to_d
    created = Payment.generate_monthly_fees!(amount: amount)
    puts "Generated #{created} monthly charge(s) of #{amount}."
  end

  desc "Apply 2% late fees to overdue charges (idempotent)"
  task apply_late_fees: :environment do
    created = Payment.apply_late_fees!(percentage: 2.0)
    puts "Applied #{created} late fee(s)."
  end

  desc "Run full billing cycle: overdue sweep + late fees"
  task billing_cycle: %i[mark_overdue apply_late_fees]
end
