FROM onlyoffice/documentserver:latest

### Why is this needed? ###
# Because OnlyOffice are some f****** r******* a****** there likes to ruin the life for everyone.
#
# OnlyOffice removed the function to edit document in the web-browser on mobile platforms from there DocumentServer Community Edition
# Source: https://help.nextcloud.com/t/onlyoffice-removed-web-mobile-editing-from-version-5-5-0-of-community-document-server/74360
#
# There exists a fix there is easy to implement and that is what this script does.
# The fix is from the 23/03/2020 and I (Dennis) don't for how long it will work,
# but if we no longer can edit document on our mobile devices in the web-browser when it probably stopped working
# https://help.nextcloud.com/t/onlyoffice-removed-web-mobile-editing-from-version-5-5-0-of-community-document-server/74360/46
#
# DocumentServer - https://github.com/ONLYOFFICE/DocumentServer.


### Applying the patch ###
# by replace
# isSupportEditFeature:function(){return!1}
# with
# isSupportEditFeature:function(){return 1}

RUN sed -i 's/isSupportEditFeature:function\(\)\{return!1\}/isSupportEditFeature:function(){return 1}/' -r /var/www/onlyoffice/documentserver/web-apps/apps/*/mobile/app.js

