# Ssh::Manager

Simplify the usage of multiple ssh connection by managing them at one place


## Installation

Add this line to your application's Gemfile:

    gem 'ssh-manager'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ssh-manager

## Usage


Usage: sshm [options] ...

    -a, --add ip                     Add ip to your Connection list

    -c, --connect id                 connect to <id>

    -d, --delete id                  delete connection <id>

    -u, --update id                  update connection <id>

    -s, --search string              search connection for given criteria

    -l, --list                       list all connections

    -h, --help                       Display this screen

    -v, --version                    Print programs version



`sshm -l`


Listing ..
    ID IP                  USERNAME            HOSTNAME            PORT                NOTES

    1: 10.120.66.8         user                hostname            22                  mylap

    2: 192.168.0.14        user                hostname            22                  phone

    3: 10.120.4.63         user                hsotname            22                  worklap

    4: 192.168.0.193       user                hostname            22                  rasp home




`sshm -u [1-5]`

`sshm -d [1-5]`

`sshm -c [1-5]`

or quickconnect

`sshm [1-5]`



## Config

Configfile and database is located in ~/.config/sshm/

Change the `terminal` entry to your prefered term.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
