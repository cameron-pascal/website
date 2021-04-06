#! /bin/sh

# Make sure parameters are set:
if [ $# != 5 ]; then
     echo "Incorrect number of arguments. Expected 5."
     echo "Usage: dest_user dest_host dest_dir cf_zone cf_token"
     exit 1
fi

dest_user=$1
dest_host=$2
dest_dir=$3
cf_zone=$4
cf_token=$5

# Create dist directory that only contains the files to be published.
echo "---Packaging website.---"
rm -rf dist
rsync -avr --exclude='.git' --exclude='.gitignore' --exclude='.github' --exclude='README.md' --exclude='publish.sh' ./ dist

ret_code=$?
if [ $ret_code != 0 ]; then
     printf "Packaging failed. rsync returned code %d\n" $ret_code
     exit 1
fi

echo "Done.\n"

# Remove currently published files.
echo "---Removing old website from remote.---"
ssh "$dest_user@$dest_host" "rm -rf $dest_dir"

ret_code=$?
if [ $ret_code != 0 ]; then
     printf "Removing old website failed. ssh returned code %d\n" $ret_code
     exit 1
fi

echo "Done.\n"

# Publish new files.
echo "---Publishing new website to remote.---"
scp -r dist "$dest_user@$dest_host":"$dest_dir"

ret_code=$?
if [ $ret_code != 0 ]; then
     printf "Publishing new website failed. ssh returned code %d\n" $ret_code
     exit 1
fi

echo "Done.\n"

# Purge Cloudflare cache.
echo "---Purging Cloudflare cache.---"
curl -sS -X POST "https://api.cloudflare.com/client/v4/zones/$cf_zone/purge_cache" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $cf_token" \
     --data '{"purge_everything":true}' \
     -o /dev/null

ret_code=$?
if [ $ret_code != 0 ]; then
     printf "Purging Cloudflare cache failed. ssh returned code %d" $ret_code
     exit 1
fi

echo "Done."