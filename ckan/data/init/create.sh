APIKEY="6fde06e5-0cb2-462d-9ff1-74ae1ebfac4a"

HOST=agid.geo-solutions.it
#HOST=localhost:5000


for file in orgs/*.json; do
   echo CREATE ORG from file $file
   curl -i -H "X-CKAN-API-Key: $APIKEY" -XPOST -d @$file http://$HOST/api/3/action/organization_create
done

for file in groups/*.json; do
   echo CREATE GROUP from file $file
   curl -i -H "X-CKAN-API-Key: $APIKEY" -XPOST -d @$file http://$HOST/api/3/action/group_create
done

for file in sources/*.json; do
   echo CREATE SOURCE from file $file
   curl -i -H "X-CKAN-API-Key: $APIKEY" -XPOST -d @$file http://$HOST/api/3/action/package_create
done

