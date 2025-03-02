########################
# FOR A COMPLETE BUILD #
########################

Inside the cvw repository:
1) `export WALLY=$(pwd)`
2) `$WALLY/bin/wally-tool-chain-install.sh --clean $(pwd)/wally-toolchain-$(date +%Y%m%d)`
3) `tar -zcvf wally-toolchain-$(date +%Y%m%d).tar.gz wally-toolchain-$(date +%Y%m%d)`
4) `mv wally-toolchain-$(date +%Y%m%d).tar.gz /path/to/suitable/location`
5) `sudo cp $WALLY/bin/site-setup.sh /path/to/suitable/location/wally-toolchain-$(date +%Y%m%d)/site-setup.sh`
Afterwards, update setup.sh scripts in Wally repo to point to the new toolchain

#################################
# FOR LEAVING OUT THE BUILDROOT #
#################################

Inside the cvw repository:
1) `export WALLY=$(pwd)`
2) `$WALLY/bin/wally-tool-chain-install.sh --clean --no-buildroot $(pwd)/wally-toolchain-nobr-$(date +%Y%m%d)`
3) `tar -zcvf wally-toolchain-nobr-$(date +%Y%m%d).tar.gz wally-toolchain-nobr-$(date +%Y%m%d)`
4) `mv wally-toolchain-nobr-$(date +%Y%m%d).tar.gz /path/to/suitable/location`
5) `sudo cp $WALLY/bin/site-setup.sh /path/to/suitable/location/wally-toolchain-nobr-$(date +%Y%m%d)/site-setup.sh`
Afterwards, update setup.sh scripts in Wally repo to point to the new toolchain
