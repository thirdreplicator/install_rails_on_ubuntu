# Ubuntu 8.04 installation script

# Note: Change mysite.com to the name of your website.

# Update the system

sudo sed -i -e's/main universe/main universe multiverse/' /etc/apt/sources.list
sudo apt-get update
sudo apt-get -y upgrade

# Basic configurations

echo 'alias s=sudo' >> ~/.bashrc
echo "alias sgi=\'sudo gem install --no-ri --no-rdoc'" >> ~/.bashrc
sudo sed -i -e's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config

# Basic software packages

export DEBIAN_FRONTEND=noninteractive
sudo apt-get -y install bind9
sudo apt-get install -y git-core
sudo apt-get -y install apache2
sudo apt-get -y install mysql-client
sudo apt-get -y install mysql-server

sudo apt-get install -y postfix postfix-mysql
sudo apt-get install -y apache2-prefork-dev
sudo apt-get install -y libapr1-dev # Not necessary actually.
sudo apt-get install -y libaprutil1-dev # Not necessary actually.
sudo apt-get install -y autoconf
sudo apt-get install libcurl4-openssl-dev
sudo apt-get install tk

# Install ruby 1.9.1

sudo apt-get install wget
sudo apt-get -y install libc6-dev libssl-dev libmysql++-dev libsqlite3-dev make build-essential libssl-dev libreadline5-dev zlib1g-dev
cd ~ ;
mkdir -p src ;
cd src/ ;
wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.1-p129.tar.gz;
tar xzvf ruby-1.9.1-p129.tar.gz ;
cd ruby-1.9.1-p129/ ;
./configure --prefix=/usr/local --with-openssl-dir=/usr --with-readline-dir=/usr --with-zlib-dir=/usr  ;
make && sudo make install ;

# Install gems

sudo gem install rails sqlite3-ruby rubygems-update test-unit capistrano git haml authlogic
gem install rubygems-update

# Install the MySQL gem

cd ~/src;
wget http://rubyforge.org/frs/download.php/51087/mysql-ruby-2.8.1.tar.gz;
tar xzvf mysql-ruby-2.8.1.tar.gz;
cd mysql-ruby-2.8.1;
sudo ruby extconf.rb;
make;
sudo make install

# Install Git

cd ~/src
wget http://www.codemonkey.org.uk/projects/git-snapshots/git/git-latest.tar.gz
tar -xzvf git*.gz
cd git*
autoconf
./configure --with-curl=/usr # for git-http-push
make
make install

# Install SQLite

sudo apt-get install -y sqlite3 libsqlite3-dev
sudo gem install --no-rdoc --no-ri sqlite3-ruby

# Set up Phusion passenger

sudo gem install --no-ri --no-rdoc passenger
sudo passenger-install-apache2-module --auto
passenger-install-apache2-module
cat >> /etc/apache2/httpd.conf <<EOM
ServerName www.mysite.com
LoadModule passenger_module /usr/local/lib/ruby/gems/1.9.1/gems/passenger-2.2.5/ext/apache2/mod_passenger.so
PassengerRoot /usr/local/lib/ruby/gems/1.9.1/gems/passenger-2.2.5
PassengerRuby /usr/local/bin/ruby
EOM
/etc/init.d/apache2 reload

# Configure mod_rails for a fast production server

cat > /etc/apache2/conf.d/mod_rails.conf <<EOM
PassengerHighPerformance on
PassengerPoolIdleTime 172800
PassengerStatThrottleRate 3600
RailsBaseURI /
RailsFrameworkSpawnerIdleTime 0
RailsAppSpawnerIdleTime 0
EOM



# Configure Apache for mysite.com

cat > /etc/apache2/sites-available/mysite.com <<EOM
<VirtualHost *:80>
ServerName www.mysite.com
ServerAlias mysite.com
DocumentRoot /var/www/mysite.com/production/current/public
ErrorLog /var/log/apache2/mysite.com.err
CustomLog /var/log/apache2/mysite.com.log  combined
Include /etc/apache2/conf.d/mod_rails.conf
</VirtualHost>
EOM

a2ensite mysite.com

mkdir -p /var/www/mysite.com/production
/etc/init.d/apache2 reload




