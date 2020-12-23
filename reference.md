<!-- Deploy to Heroku -->
git push heroku main

<!-- Migrate DB changes to Heroku -->
heroku run rake db:migrate

<!-- Heroku console -->
heroku run rails console

<!-- Setting Heroku env keys -->
heroku config:set API_KEY=put-your-api-key-here

<!-- Clear Sidekiq queue -->

require 'sidekiq/api'
Sidekiq::Queue.new("infinity").clear
Sidekiq::RetrySet.new.clear
Sidekiq::ScheduledSet.new.clear
Sidekiq::Queue.all.map(&:clear)
Sidekiq::RetrySet.new.clear
Sidekiq::ScheduledSet.new.clear
Sidekiq::DeadSet.new.clear
Sidekiq.redis(&:flushdb)

<!-- Kill Postgres connections to reset DB -->

ps -ef | grep postgres
sudo kill -9 {PID of the connection}