# Hobo on Amazon EC2

Originally written by brett on 2010-11-05.

A minimal setup guide to getting Hobo running on a Tiny 32 bit Linux EC2 instance.


     sudo yum erase ruby
     sudo yum groupinstall 'Development Tools'
     sudo yum install readline-devel

     bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head )

     rvm package install openssl
     rvm install 1.9.2 --with-openssl-dir=$HOME/.rvm/usr

     gem install sqlite3
     gem install rails -v 2.3.5
     gem install hobo


Enjoy!

