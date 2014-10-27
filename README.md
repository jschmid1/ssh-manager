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

1. 192.168.0.1 | your first connection
2. 10.120.0.1 |  some
3. 192.168.1.1 | more
4. 10.10.120.0 | connections
5. 188.42.69.88 | you added
connect to: [1-5]


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
