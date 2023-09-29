// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:android_flutter_wifi/android_flutter_wifi.dart' as afw;


class WifiVIew extends StatefulWidget {
  const WifiVIew({super.key});

  @override
  State<WifiVIew> createState() => _WifiVIewState();
}

class _WifiVIewState extends State<WifiVIew> {
  TextEditingController passcon = TextEditingController();

  String? wifiName = "";
  String? wifiIp = "";
  String? wifiBssid = "";
  int? wifiFreq = 0;
  int? wifiCurrentSt = 0;
  List<WifiNetwork> wifiList = [];
  bool loading = false;
  List<Map<String,String>> whiteListed = [
    {"ssid" : "asdsaf", "password": "29199532"},
    {"ssid" : "Miracle", "password": "Miracle@2021"},
    {"ssid" : "TP-LINK_EF33_5G", "password": "29199532"}
  ];


  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  @override
  void dispose() {
    super.dispose();
  }
  

  fetchAll() async  {
    await getWifiInfo();
    await loadWifiList();
    bool hasSsid = false;
    Map<String,String> data ={};
    for (var i = 0; i < whiteListed.length; i++) {
      if(wifiList.map((e) => e.ssid.toString()).toList().contains(whiteListed[i]['ssid'])) {
        hasSsid = true;
        data = whiteListed[i];
      }
    }

    if(hasSsid) {
      if(whiteListed.where((element) => element['ssid'].toString() == wifiName).isNotEmpty) {


        // bool result = await WiFiForIoTPlugin.connect(
        //   whiteListed[0]['ssid'].toString(), 
        //   joinOnce: true,
        //   password: whiteListed[0]['password'].toString(),
        // );
        // if(result){
        // setState(() {
        //   fetchAll();
        // });
        // }
      } else {
        setState(() {
          passcon.text = data['password'].toString();
          _buildDialog(context, data['ssid'].toString());
        });
      }
    }
  }

  getWifiInfo() async {
    var status = await Permission.location.request();
    if (status.isDenied) {
    }
    if (await Permission.location.isRestricted) {
    }
    if(status.isGranted){
        wifiName = await WiFiForIoTPlugin.getSSID();
        wifiIp =  await WiFiForIoTPlugin.getIP();
        wifiFreq = await WiFiForIoTPlugin.getFrequency();
        wifiCurrentSt = await WiFiForIoTPlugin.getCurrentSignalStrength();
        wifiBssid = await WiFiForIoTPlugin.getBSSID();
        setState(() {
          
        });
    }
  }

  disconnect() async {

    if(whiteListed.map((e) => e["ssid"]).toList().contains(wifiName!.replaceAll(RegExp(r'"'), '')) == false  ){
      bool result = await WiFiForIoTPlugin.disconnect();
      if(result){
        log("Disconnected");
      } else {
        log("Error Disconnection");

      }
    }
  }

  
  Future<List<WifiNetwork>> loadWifiList() async {
    wifiList.clear();
    loading = true;
    List<WifiNetwork> htResultNetwork;
    try {
      htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      htResultNetwork = <WifiNetwork>[];
    }
    log(htResultNetwork.map((e) => e.ssid).toString());
    wifiList.addAll(htResultNetwork);
    setState(() {
      loading = false;
    });
    return htResultNetwork;
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: _buildFloating(),
        body: _buildWifiView()      
      ),
    );
  }

  _buildWifiView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //conected 
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 15),
            child: Text("Connected To :", style: const TextTheme().bodyMedium,),
          ),
          Card(
            elevation: 5,
            margin: const EdgeInsets.all(15),
            shape: Border.all(color: Colors.green),
            child: ListTile(
              onTap: () async {
                afw.ActiveWifiNetwork dhcpInfo = await afw.AndroidFlutterWifi.getActiveWifiInfo();
                log(dhcpInfo.toString());
                bool a = await afw.AndroidFlutterWifi.forgetWifiWithSSID(dhcpInfo.ssid.toString());
                log(a.toString());
              },
              title: Text(wifiName.toString()),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wifiBssid.toString()),
                  Text(wifiIp.toString()),
                  Text(wifiFreq.toString()),
                  Text(wifiCurrentSt.toString()),
                ],
              ),
            ),
          ),


          loading 
            ? const Center(
              child: CircularProgressIndicator(),
            )
            : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(15),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wifiList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () async {
                    _buildDialog(context, wifiList[index].ssid.toString());
                  },
                  title: Text(wifiList[index].ssid.toString()),
                  subtitle: Text(wifiList[index].bssid.toString()),
                  trailing: wifiName!.replaceAll(RegExp(r'"'), '') == wifiList[index].ssid.toString() 
                    ? const Text( "Connected", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold ))
                    : Container(
                      width: 1,
                    )
                );
              }, 
            )
    
        ],
      ),
    );
  }
  
  void _buildDialog(BuildContext context, String ssid) {
    bool connecting = false;
    showDialog(context: context, 
      barrierDismissible: false,
      builder: (context) => 
        AlertDialog(
          title: Text(ssid.toString(),),
          content: StatefulBuilder(
            builder: (context, setState) => 
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passcon,
                  decoration: const InputDecoration(
                    hintText: "Password"
                  ),
                ),
                MaterialButton(
                  onPressed: () async {                 
                      setState((){
                        connecting=true;
                      }); 
                      bool result = await WiFiForIoTPlugin.
                      connect(
                        ssid.toString(), 
                        // bssid: wifiList[index].bssid.toString(),
                        // isHidden: false,
                        // joinOnce: true,
                        password: passcon.text,
                        security: NetworkSecurity.WPA,
                        // withInternet: true,
                        // timeoutInSeconds: 5  
                      );
                      // WiFiForIoTPlugin.showWritePermissionSettings(true);
                      // bool? result = await PluginWifiConnect.connectToSecureNetworkByPrefix(ssid.toString(), passcon.text, isWpa3: true ,saveNetwork: true);
                      if(result == true){
                        bool wifiusage = await WiFiForIoTPlugin.forceWifiUsage(true);
                        log("Connected To : $ssid");
                        log("wifi usage : $wifiusage");
                        setState(() {
                          connecting=false;
                          Navigator.pop(context);
                          fetchAll();
                        });
                      } else {
                        setState((){
                          connecting=false;
                        });
                        log("Error connecting to $ssid");
                      }
                    passcon.clear();

                  },
                  color: Colors.green,
                  child: Text(connecting ? "Connecting..." : "Connect", style: const TextStyle(color: Colors.white), ),
                )
              ],
            ),
          )
        )
    );
  }
  
  _buildFloating() {
    final ssidCon = TextEditingController();
    final passCon = TextEditingController();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          tooltip: 'refresh',
          onPressed: () {
            setState(()  {
              fetchAll();
              // getWifiNames();
              // loadWifiList();
            });
          },
          child: const Icon(Icons.refresh)
        ),
        const SizedBox(
          width: 10,
        ),
        FloatingActionButton(
          tooltip: 'disconnect',
          onPressed: () async{
            await WiFiForIoTPlugin.forceWifiUsage(false);
            disconnect();
          },
          child: const Icon(Icons.close)
        ),
        const SizedBox(
          width: 10,
        ),
        FloatingActionButton(
          tooltip: 'add to whiteList',
          onPressed: () async{
            showModalBottomSheet(
              context: context, 
              builder: (context) => 
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      const Center(
                        child: Text("Whitelist"),
                      ),
                      TextField(
                        controller: ssidCon,
                        decoration: const InputDecoration(
                          hintText: "Ssid",
                        ),
                      ),
                      TextField(
                        controller: passCon,
                        decoration: const InputDecoration(
                          hintText: "Password",
                        ),
                      ),
                      MaterialButton(
                        child: const Text("Add"),
                        onPressed: () {
                          whiteListed.add({
                            "ssid": ssidCon.text,
                            "password": passCon.text
                          });
                          Navigator.pop(context);
                        }
                      )
                    ],
                  ),
                ),
            );
          },
          child: const Icon(Icons.add)
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}