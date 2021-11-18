# deb-builder
Super simple bash script to create a deb file

### Install
Warning, running as root may cause errors.

make sure `git` and `dpkg-dev` are installed.

```
# setup
git clone https://github.com/ryanfortner/deb-builder.git
cd deb-builder
chmod +x deb-builder.sh

# run
./deb-builder.sh
```

### Notes
- Be sure to have a directory before running the script containing the files you want to be in the deb.
- For example, if I wanted a script in /usr/bin to be in my deb, I would make a directory, and make another two subdirectories, and place my file within `pre-dir/usr/bin/`.
