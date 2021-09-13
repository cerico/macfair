.PHONY: db tldr
createdb:
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
	bundle exec rake db:setup
elastic:
	ES_JAVA_OPTS="-Xms1g -Xmx1g" ~/elasticsearch-7.14.1/bin/elasticsearch &
index:
	bundle exec rake elasticsearch:rebuild_index ALIAS_NOW=true
redis:
	redis-server &
install:
	bundle install
	yarn install --check-files
webpack:
	./bin/webpack-dev-server &
rails:
	rails s -b 0.0.0.0
tldr:
	echo "How do I get started? \n\
\n\
make createdb\nmake elastic\nmake index\nmake redis\nmake install\nmake webpack\nmake rails"
