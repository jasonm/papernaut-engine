Deploying to production
=======================

Heroku is recommended for the papernaut-engine web application.

Set the following required environment variables:

```
SECRET_TOKEN:                   (redacted)...
ZOTERO_TRANSLATION_SERVER_URL:  ec2-whatever.us-east-1.compute.amazonaws.com:1969
```

Running the zotero/translation-server on EC2
--------------------------------------------

* Start with a lucid/ebc AMI: ami-fe5bd4ce
* Using lucid because some xulrunner-sdk prereqs are satisfied neatly by the
  xulrunner-dev apt package, which isn't available in newer repo.
  This could be improved.

```bash
  sudo apt-get update
  sudo apt-get install xulrunner-dev git-core

  mkdir dev ; cd dev

    wget http://ftp.mozilla.org/pub/mozilla.org/xulrunner/releases/14.0.1/sdk/xulrunner-14.0.1.en-US.linux-x86_64.sdk.tar.bz2
    tar xvf xulrunner-14.0.1.en-US.linux-x86_64.sdk.tar.bz2

    git clone https://github.com/zotero/translation-server.git
    cd translation-server

      ln -s ../xulrunner-sdk

      git submodule init
      git submodule update
      cd modules/zotero
        git submodule init
        git submodule update
        cd ../..

      echo "update config directory:"
      ls -d ~/dev/translation-server/modules/zotero/translators
      grep translation-server.translatorsDirectory config.js
      echo "use vim or nano or whatever, but you've gotta update it ^^"

      ./build.sh
      build/run_translation-server.sh
```

* Try a query!

```bash
curl -d '{"url":"http://www.nature.com/nature/journal/v493/n7430/full/493036a.html","sessionid":"abc123"}' \
     --header "Content-Type: application/json" \
     localhost:1969/web
```

* Or:

```bash
cd ~/dev/journalclub/engine

ZOTERO_TRANSLATION_SERVER_URL=ec2-54-245-21-171.us-west-2.compute.amazonaws.com:1969 \
    rails runner "Page.unidentified.first.identify"
```
