# basic gitspam

Every few months I need commitspam and have to look it up again how to do it.

## Instructions for simple and probably more reliable xinetd method

  * Install ruby stuff, use chruby or something:
```
gem install git-commit-notifier
```
  * checkout this repo, I used `/opt/commitspam` (paths are hardcoded, sorry)
```
cd /opt
git clone https://github.com/winks/commitspam.git commitspam
```
  * copy (and possibly adapt) the config template.
```
cp config.template.yml.dist config.template.yml
```

  * optional: copy config.rb and overwrite some values
    you can try to install and run git-commit-notifier with chruby etc. I gave up.

  * configure one of your repos
```
#                           repository to clone                     foldername sender address   receiver address
#                           |                                       |          |                |
#                           v                                       v          v                v
/opt/commitspam/new-repo.sh https://github.com/winks/commitspam.git commitspam from@example.org to@example.org
```

  * you should now have something like this:
```
total 60K
-rwxr-xr-x  1 winks  546 Oct  9 19:27 change-notify.sh*
-rw-r--r--  1 winks  403 Oct 24 08:52 commitspam.xinetd
-rw-r--r--  1 winks 8.7K Oct  9 19:28 config_commitspam.yml
-rw-r--r--  1 winks 8.7K Oct  9 19:29 config.template.yml
-rw-r--r--  1 winks  182 Oct  9 19:29 config.rb
drwxr-xr-x 11 winks 4.0K Oct  9 19:06 commitspam/
-rwxr-xr-x  1 winks  544 Oct 10 00:37 new-repo.sh*
-rw-r--r--  1 winks  573 Oct 10 00:42 README.md
-rwxr-xr-x  1 winks  863 Oct 24 09:04 spawn.rb*
-rw-r--r--  1 winks  565 Oct 10 00:36 webhook.rb
```

  * enable your webhook: (change the user/group if needed)
```
sudo apt-get install xinetd
sudo ln -s /opt/commitspam/commitspam.xinetd /etc/xinetd.d/commitspam
sudo service xinetd restart
```

  * edit your settings at https://github.com/USERNAME/REPONAME/settings/hooks
and add http://yourhost.example.org:8060

  * enjoy


## Instructions for less simple and (probably less) reliable daemon method

  * Install ruby stuff, use chruby or something:
```
gem install sinatra
gem install thin
gem install git-commit-notifier
```
  * checkout stuff, I used `/opt/commitspam` (paths are hardcoded, sorry)
```
cd /opt
git clone https://github.com/winks/commitspam.git commitspam
```

  * configure one of your repos
```
/opt/commitspam/new-repo.sh https://github.com/winks/commitspam.git commitspam from@example.org to@example.org
```

  * you should now have something like this:
```
total 60K
-rwxr-xr-x  1 winks  546 Oct  9 19:27 change-notify.sh*
-rw-r--r--  1 winks 8.7K Oct  9 19:28 config_commitspam.yml
-rw-r--r--  1 winks 8.7K Oct  9 19:29 config.template.yml
-rw-r--r--  1 winks  182 Oct  9 19:29 config.rb
drwxr-xr-x 11 winks 4.0K Oct  9 19:06 commitspam/
-rwxr-xr-x  1 winks  544 Oct 10 00:37 new-repo.sh*
-rw-r--r--  1 winks  573 Oct 10 00:42 README.md
-rw-r--r--  1 winks  565 Oct 10 00:36 webhook.rb
```

  * fire up your webhook: (obviously do not use development mode)
```
ruby webhook.rb

#== Sinatra/1.3.3 has taken the stage on 8060 for development with backup from Thin
```

  * edit your settings at https://github.com/USERNAME/REPONAME/settings/hooks
and add http://yourhost.example.org:8060

  * enjoy

## TODO

  * Github Webhook IPs are hardcoded multiple times.
    * Probably in commitspam.xinetd, spawn.rb and webhook.rb
    * Check them at https://api.github.com/meta
  * This is still a hack
  * It *seems* to work behind nginx

## Acknowledgement

  * https://github.com/git-commit-notifier/git-commit-notifier rocks
  * they also provided most of the samples, I just made them ready to use
  * @codec and @fpletz for the idea/code for xinetd
