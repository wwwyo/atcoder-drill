namespace :atcoder_drill do
  desc "slackにatcoderの問題を転送"
  task :drill_cron => :environment do 
    Cron.new.drill_cron
  end
end
