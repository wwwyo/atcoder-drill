require File.expand_path(File.dirname(__FILE__) + "/environment")
set :output, "#{Rails.root}/log/cron.log"
env :PATH, ENV['PATH']

rails_env = ENV['RAILS_ENV'] || :development
# cronを実行する環境変数をセット
set :environment, rails_env
# rbenvを初期化
set :job_template, "/bin/zsh -l -c ':job'"
job_type :rake, "export PATH=\"$HOME/.rbenv/bin:$PATH\"; eval \"$(rbenv init -)\"; cd :path && RAILS_ENV=:environment bundle exec rake :task :output"

every 1.days, at: '9:00 am' do
  begin
    rake "atcoder_drill:drill_cron" 
  rescue => e
    Rails.logger.error(e)
    raise e
  end
end