.PHONY: db
setup:
	pip3 install ansible --user
	~/Library/Python/3.8/bin/ansible-galaxy install -r requirements.yml
	~/Library/Python/3.8/bin/ansible-playbook setup.yml -i hosts -l local --ask-become-pass
db:
	echo "default: &default\n\
  adapter: postgresql\n\
  encoding: unicode\n\
  pool: 5\n\
\n\
development:\n\
  <<: *default\n\
  database: fleetnation_development\n\
\n\
test:\n\
  <<: *default\n\
  database: fleetnation_test \n" > ~/fleetnation/config/database.yml
prepare:
	ES_JAVA_OPTS="-Xms1g -Xmx1g" ~/elasticsearch-7.14.1/bin/elasticsearch &
	redis-server &
	bundle install
	yarn install --check-files
	bundle exec rake db:setup
	bundle exec rake elasticsearch:rebuild_index ALIAS_NOW=true
	./bin/webpack-dev-server &
start:
	rails s -b 0.0.0.0
