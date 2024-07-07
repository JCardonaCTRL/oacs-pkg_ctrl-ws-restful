ad_library {

    Procedures to interface with Pushapp SN

    @author KH
    @cvs-id $Iid$
    @creation-date 2014-09-24
} 


namespace eval ctrl::pushapp::api  {
    

}

ad_proc ctrl::pushapp::api::register_device {
    -secret_token:required
    -push_token:required
    -device_id
    -custom_id 
    -device_type
    -os_version
    -sdk_version
    -device_description 
    -app_version
    -time_zone
    -sdk_type
    -app_identifier
} {

    @option secret_token The token received from PushApps for using the Remote API
    @option push_token he token received from Google or Apple by the device
    @option device_id A unique string within this app to identify this device. Could be the IMEI in Android for example or UDID on iOS
    @pption custom_id Custom id that represents the device.
    @option device_type 
    @option os_version This device operating system version
    @option sdk_version Pushapps sdk version
    @option device_description The hardware of the device, i.e "iPhone 5"
    @option app_version This app current version
    @option time_zone The device's offset from UTC in minutes. For example, UTC +01:00 will be 60
    @option sdk_type The device's sdk type

} {


    


}