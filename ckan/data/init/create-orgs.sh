APIKEY=${1:?"Missing APIKEY param"}
HOST=${2:?"Missing HOST param"}

DIR=$(dirname "${BASH_SOURCE[0]}")

echo === START OF ITEMS CREATION
echo == Data init dir is $DIR

for file in $DIR/orgs/*.json; do
   echo = CREATE ORG from file $file
   curl -i -H "X-CKAN-API-Key: $APIKEY" -XPOST -d @$file http://$HOST/api/3/action/organization_create
done

echo === END OF ITEMS CREATION
