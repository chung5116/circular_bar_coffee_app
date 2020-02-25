import 'dart:async';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'BluetoothDeviceListEntry.dart';

class SearchDevicePage extends StatefulWidget {
  final bool start;
  const SearchDevicePage({this.start = true});

  @override
  _SearchDevicePage createState() =>new _SearchDevicePage();
}

class _SearchDevicePage extends State<SearchDevicePage> {
  StreamSubscription<BluetoothDiscoveryResult>_streamSubscription;
  List<BluetoothDiscoveryResult>results = List<BluetoothDiscoveryResult>();
  bool isDiscovering;

  @override
  void initState() {
    super.initState();
    isDiscovering = widget.start;
    if(isDiscovering){
      _startDiscovery();
    }
  }


  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery(){
    _streamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((r){
      setState((){results.add(r);});
    });
    _streamSubscription.onDone((){
      setState(() {isDiscovering = false;});
    });
  }


  @override
  void dispose() {
    //FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _streamSubscription?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: isDiscovering?Text('Discovery devices'):Text('Discoverd devices'),
          actions: <Widget>[
            (
                isDiscovering?
                FittedBox(child: Container(
                    margin: new EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                ))
                    :
                IconButton(
                    icon: Icon(Icons.replay),
                    onPressed: _restartDiscovery
                )
            )
          ],
        ),
        body: ListView.builder(
          itemCount: results.length,
          itemBuilder: (BuildContext context,index){
            BluetoothDiscoveryResult result = results[index];
            return BluetoothDeviceListEntry(
              device: result.device,
              rssi: result.rssi,
              onLongPress: () {
                //Navigator.of(context).pop(result.device);
                print('pop');
              },
              onTap: ()async{
                try{
                  bool bonded = false;
                  if (result.device.isBonded ){
                    print('Already bonding from ${result.device.address}...');
                    Navigator.of(context).pop(result.device);
                  }
                  else{
                    print('Bonding with ${result.device.address}...');
                    bonded = await FlutterBluetoothSerial.instance.bondDeviceAtAddress(result.device.address);
                    print('Bonding with ${result.device.address} has ${bonded ? 'succed' : 'failed'}.');
                    if(bonded!=null){
                      Navigator.of(context).pop(result.device);
                    }
                    //如果沒連結成功
                  }
                  setState(() {
                    results[results.indexOf(result)] = BluetoothDiscoveryResult(
                        device: BluetoothDevice(
                          name: result.device.name ?? '',
                          address: result.device.address,
                          type: result.device.type,
                          bondState: bonded ? BluetoothBondState.bonded : BluetoothBondState.none,
                        ),
                        rssi: result.rssi
                    );
                    print('setState');
                  });
                }
                catch(ex){
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: const Text('Error occured while bonding'),
                          content: Text("${ex.toString()}"),
                          actions: <Widget>[
                            new FlatButton(
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                                child: new Text('Close'))
                          ],
                        );
                      }
                  );
                }
              },
            );
          },
        )
    );
  }
}