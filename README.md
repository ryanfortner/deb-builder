# deb-builder
Super simple bash script to create Debian packages

### Running
Warning, running as root may cause errors.

make sure `git` and `dpkg-dev` are installed.

```
# setup
git clone https://github.com/ryanfortner/deb-builder.git
cd deb-builder
chmod +x deb-builder.sh

# run deb builder
./deb-builder.sh
```

### Notes
- Be sure to have a directory before running the script containing the files you want to be in the deb.
- For example, if I wanted a script in /usr/bin to be in my deb, I would make a directory, and make another two subdirectories, and place my file within `pre-dir/usr/bin/`.
- When you get to the control file creation part, you may be able to exclude certain fields. Check [this page](https://www.debian.org/doc/debian-policy/ch-controlfields.html) for optional and required entries.
- Open an issue on this repository if you encounter any problems.
