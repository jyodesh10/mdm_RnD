

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothView extends StatefulWidget {
  const BluetoothView({super.key});

  @override
  State<BluetoothView> createState() => _BluetoothViewState();
}

class _BluetoothViewState extends State<BluetoothView> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;

  List<String> whiteListed = ["Redmi Buds 3 Lite"];
  List<BluetoothDevice> bondedDevices = [];

  @override
  void initState() {
    // scanBle();
    super.initState();
    _startDiscovery();
    _getBonded();

  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription!.cancel();
  }

  removeDevices() async {
    for (var i = 0; i < bondedDevices.length; i++) {
       if(whiteListed.contains(bondedDevices[i].name )== false){
        bool? result = await FlutterBluetoothSerial.instance.removeDeviceBondWithAddress(bondedDevices[i].address.toString());
        if(result == true){
          setState(() {
            bondedDevices.remove(bondedDevices[i]);
            Navigator.pop(context);
          });
        }
       }
    }
  }

  _getBonded() async {
    bondedDevices = await FlutterBluetoothSerial.instance
        .getBondedDevices();
    removeDevices();
    setState(() {
      
    });
  }

  void _startDiscovery() async {
    await FlutterBluetoothSerial.instance.cancelDiscovery();

    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        final existingIndex = results.indexWhere(
            (element) => element.device.address == r.device.address);
        if (existingIndex >= 0) {
          results[existingIndex] = r;
        } else {
          results.add(r);
        }
      });
    });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });

  }

  final nameCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFloating(),
      body: Container(
        margin: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: MaterialButton(
                  color: Colors.amber,
                  onPressed: (){
                    // scanBle();
                    // scanFlutterBlue();
                    _startDiscovery();
                    _getBonded();
                  },
                  child: const Text("Scan"),
                ),
              ),
              const Text("Bonded Devices", style: TextStyle(fontSize: 20),),
              bondedDevices.isEmpty ? const Center(child : Text("No Bonded Devices") ) : Container(),
              ...List.generate(bondedDevices.length, (index) => 
                ListTile(
                  title: Text(bondedDevices[index].name.toString()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bondedDevices[index].address.toString()),
                      Text(bondedDevices[index].type.stringValue.toString()),
                    ],
                  ),
                  trailing: IconButton(onPressed: () async {
                      showDialog(context: context, builder: (context) => Dialog.fullscreen(
                        backgroundColor: Colors.white.withOpacity(0.4),
                        child: const Center(child: CircularProgressIndicator()),
                      ),);
                      bool? result = await FlutterBluetoothSerial.instance.removeDeviceBondWithAddress(bondedDevices[index].address.toString());
                      if(result == true){
                        setState(() {
                          bondedDevices.remove(bondedDevices[index]);
                          Navigator.pop(context);
                        });
                      }
                    }, 
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20, )
                  ) 
                ),
              ),
              const Divider(),
              const Text("Discoverable Devices", style: TextStyle(fontSize: 20),),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                itemBuilder: (context, index) => results[index].device.name != null
                  ? ListTile(
                    title: Text(results[index].device.name.toString()),
                    subtitle: Text(results[index].device.address),
                    trailing: 
                    whiteListed.contains(results[index].device.name.toString())
                      ? IconButton(onPressed: () async {
                        showDialog(context: context, builder: (context) => Dialog.fullscreen(
                          backgroundColor: Colors.white.withOpacity(0.4),
                          child: const Center(child: CircularProgressIndicator()),
                        ),);
                        bool? result = await FlutterBluetoothSerial.instance. bondDeviceAtAddress(results[index].device.address);
                        if(result == true){
                          setState(() {
                            _startDiscovery();
                            _getBonded();
                            results.remove(results[index]);
                            Navigator.pop(context);

                          });
                        } else {
                          setState(() {
                            Navigator.pop(context);
                          });
                        }
                      }, icon: const Icon(Icons.bluetooth_audio_rounded))
                      : const SizedBox(width: 1,)
                  )
                  : Container()
              )
            ],  
          ),
        ),
      )
    );
  }
  
  _buildFloating() {
    return FloatingActionButton(
      tooltip: 'add whitelist',
      onPressed: () {
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
                      controller: nameCon,
                      decoration: const InputDecoration(
                        hintText: "Bluetooth device name",
                      ),
                    ),
                    MaterialButton(
                      child: const Text("Add"),
                      onPressed: () {
                        whiteListed.add(nameCon.text);
                        Navigator.pop(context);
                      }
                    )
                  ],
                ),
              ),
          );
      },
      child: const Icon(Icons.add) 
    );
  }
}