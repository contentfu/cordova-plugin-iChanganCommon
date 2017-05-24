       var exec = require('cordova/exec');
       module.exports = {
       download : function(url,success, error) {
               exec(success, error, "iChanganCommon", "download", [url]);
       },
       appExists : function(name, success, error) {
               exec(success, error, "iChanganCommon", "appExists", [name]);
       },
       openApp : function(name, params, success, error) {
               exec(success, error, "iChanganCommon", "openApp", [name, params]);
       },
       getDeviceId:function(success, error) {
               exec(success, error, "iChanganCommon", "getDeviceId", []);
       },
       openAutoNaviRouteView:function(addressList, success, error){
               exec(success, error, "iChanganCommon", "openAutoNaviRouteView", [addressList.cur,addressList.carId, addressList.addressLists, addressList.token]);
       },
       startNavi:function(start,end,success, error){
       exec(success,error,"iChanganCommon","startNavi",[start,end]);
       },
       getLocationPermission:function(success, error){
               exec(success, error, "iChanganCommon", "getLocationPermission", []);
       },
       scanBarCode:function(success, error){
               exec(success, error, "iChanganCommon", "scanBarCode");
        },
   };
