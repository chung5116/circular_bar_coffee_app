import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'clock_page.dart';
import 'random_value_page.dart';
import 'utils.dart';
import 'dart:math' as math;
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'example_page.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'SearchDevicePage.dart';
import 'package:circular_bar_coffee_app/example_page.dart';





///example01
final customWidth01 = CustomSliderWidths(trackWidth: 2, progressBarWidth: 20, shadowWidth: 30);

final CircularSliderAppearance appearance01 = CircularSliderAppearance(
  customWidths: customWidth01,
  size: 250.0,
);
final viewModel01 = ExampleViewModel(
  appearance: appearance01,
  min: 0,
  max: 99,
  value: 0,
  pageColors: [Colors.white,HexColor('#E1C3FF')]
);
final example01 = ExamplePage(viewModel: viewModel01);





class Homepage extends StatefulWidget {

  @override
  HomepageState createState() {
    return new HomepageState();
  }
}


class HomepageState extends State<Homepage> {

  final controller = PageController(initialPage: 0);
  int valueRPM;
  //------------------------------------------------
  ///連線的
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  String _address = "...";
  String _name = "...";
  BluetoothDevice connectedDevice;
  bool pause = false;
  static final clientID = 0;
  static final maxMessageLength = 4096 - 3;
  BluetoothConnection connection;

  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = false;

  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;
  //-------------------------------------------------------------
  ///底下打字的
  final TextEditingController textEditingController = new TextEditingController();
  //-------------------------------------------------------------
  ///object
  ExamplePage example01;
  //-------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });
    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    //先創造出要用的object
    createExamplePage();

  }
  //-----------initial state----------------------------------

  Future<bool> openBT() async {
    print('request to open BT');
    await FlutterBluetoothSerial.instance.requestEnable();
    setState(() {});
    bool value = _bluetoothState.isEnabled;
    if (value) {
      print('BT is open');
      return true;
    } else if (value == false) {
      print('BT doesn\'t open');
      return false;
    }
  }

  void InitialConnect(BluetoothDevice server) {
    BluetoothConnection.toAddress(server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      isDisconnecting = false;
      //可以連線
      setState(() {
        isConnecting = true;
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      setState(() {
        isConnecting = false;
      });
      //不可連線 用顏色表示
    });
  }



  void stringToint(String text){
    textEditingController.clear();
    if(text.length>0){
      try{
        double rpm = double.parse(text);
        if(rpm>=0 && rpm<=99) {
          int rpm2 = rpm.ceil();
          //sendMessage(rpm2);
          example01.valuechange(rpm2);
        }
      }
      catch(e){
        print('輸入錯誤');
        print(e);
      }
    }
  }


  void sendMessage(int rpm) async {
    if(rpm>=0&&rpm<=99) {
      String text = rpm.toString();
      text = text.trim();
      if (text.length > 0) {
        try {
          connection.output.add(utf8.encode(text + "\r\n"));
          await connection.output.allSent;
          print('send ${text}');
        } catch (e) {
          // Ignore error, but notify state
          print('error sending');
          setState(() {
            isConnecting = false;
          });
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error occured'),
                  content: Text("請連結磨豆機"),
                  actions: <Widget>[
                    new FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: new Text('Close'))
                  ],
                );
              }
          );
        }
      }
    }
  }

  void createExamplePage() {
    final example01_local = ExamplePage(
      viewModel: viewModel01,
      //currentValue: (int val) => null,
      currentValue:(int val)=>sendMessage(val),
    );
    example01 = example01_local;
    example01.createSleekCircularSlider();
  }

  Widget hotkey(String rpmvalue){
    return Container(
      height: 65.0,
      width: 60.0,
      decoration: BoxDecoration(
        border:Border.all(
            color: Colors.grey,
            style: BorderStyle.solid,
            width: 2.0
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Center(
        child: FlatButton(
            child: Text('$rpmvalue',
                style:TextStyle(
                    fontSize: 21.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54
                )
            ),
            onPressed: (){
              print('you press $rpmvalue');
              stringToint('$rpmvalue');
            }
        ),
      ),
    );
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    FlutterBluetoothSerial.instance.requestDisable();
    print('close dispose');
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            child:example01
            /*ExamplePage(
              viewModel: viewModel01,
              currentValue: (int val)=>null,
              //currentValue:(int val)=>sendMessage(val),
            )*/
          ),

          Container(
            height: 180.0,
            width: double.infinity,
            alignment: FractionalOffset.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(width:7.0),
                hotkey('30'),
                hotkey('40'),
                hotkey('50'),
                SizedBox(width: 7.0),
              ],
            ),
          ),
          Container(
                height: 100.0,
                width: 100.0,
                alignment: FractionalOffset(0.0, 0.5),
                child: SafeArea(
                  top: false,
                  child:IconButton(
                    onPressed: () async {
                      final open = await openBT(); //回傳一個bool之類的，在bt被拒絕時不會跳畫面
                      if(open==true) {
                        final BluetoothDevice selectedDevice =
                        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return SearchDevicePage();
                        }));
                        if (selectedDevice != null) {
                          print('Discovery -> selected ' + selectedDevice.address);
                          connectedDevice = selectedDevice;
                          //建立連線
                          InitialConnect(connectedDevice);
                        } else {
                          print('Discovery -> no device selected');
                        }
                      }
                    },
                    icon: Icon(
                        isConnecting? Icons.bluetooth_audio:Icons.bluetooth_disabled
                    ),
                    iconSize: 35.0,
                  ),
                ),
              ),
          Container(
            //color: Colors.blueAccent,
            height: screenSize.height*0.97,
            width: double.infinity,
            alignment: FractionalOffset.bottomRight,
            child: SafeArea(
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      //color: Colors.blueAccent,
                      margin: const EdgeInsets.only(left: 16.0),
                      child: TextField(
                        style: const TextStyle(fontSize: 15.0),
                        controller: textEditingController,
                        decoration: InputDecoration.collapsed(
                          hintText: (
                              isConnecting ? '輸入轉速' : ' '),
                              hintStyle: const TextStyle(color: Colors.grey),
                        ),
                          enabled: isConnecting,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    child: IconButton(
                        icon: const Icon(Icons.send),
                        //onPressed:()=> stringToint(textEditingController.text)
                        onPressed: isConnecting ? ()=> stringToint(textEditingController.text) :null
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}










/*double degreeToRadians(double degree){
  return (math.pi/180)*degree;
}
///example03
final customWidth03 = CustomSliderWidths(trackWidth: 1, progressBarWidth: 20, shadowWidth: 50);

final customColors03 = CustomSliderColors(
    trackColor: HexColor('#90E3D0'),
    progressBarColors: [HexColor('#FFC84B'), HexColor('#00BFD5')],
    shadowColor: HexColor('#5FC7B0'),
    shadowMaxOpacity: 0.05);

final info03 = InfoProperties(
    bottomLabelStyle: TextStyle(
        color: HexColor('#002D43'), fontSize: 20, fontWeight: FontWeight.w700),
    bottomLabelText: 'Goal',
    mainLabelStyle: TextStyle(
        color: Color.fromRGBO(97, 169, 210, 1),
        fontSize: 30.0,
        fontWeight: FontWeight.w200),
    modifier: (double value) {
      final kcal = value.toInt();
      return '$kcal kCal';
    });
final CircularSliderAppearance appearance03 = CircularSliderAppearance(
    customWidths: customWidth03,
    customColors: customColors03,
    infoProperties: info03,
    size: 250.0,
    startAngle: 180,
    angleRange: 340);
final viewModel03 = ExampleViewModel(
    appearance: appearance03,
    min: 500,
    max: 2300,
    value: 1623,
    pageColors: [HexColor('#D9FFF7'), HexColor('#FFFFFF')]);
final example03 = ExamplePage(
  viewModel: viewModel03,
);
///example02
final customWidth02 = CustomSliderWidths(trackWidth: 1, progressBarWidth: 2);
final customColors02 = CustomSliderColors(
    trackColor: Colors.white,
    progressBarColor: Colors.orange,
    hideShadow: true);
final info02 = InfoProperties(
    topLabelStyle: TextStyle(
        color: Colors.orangeAccent, fontSize: 30, fontWeight: FontWeight.w600),
    topLabelText: 'Budget',
    mainLabelStyle: TextStyle(
        color: Colors.white, fontSize: 50.0, fontWeight: FontWeight.w100),
    modifier: (double value) {
      final budget = (value * 1000).toInt();
      return '\$ $budget';
    });
final CircularSliderAppearance appearance02 = CircularSliderAppearance(
    customWidths: customWidth02,
    customColors: customColors02,
    infoProperties: info02,
    startAngle: 180,
    angleRange: 270,
    size: 200.0,
    animationEnabled: false);
final viewModel02 = ExampleViewModel(
    appearance: appearance02,
    min: 0,
    max: 10,
    value: 8,
    pageColors: [Colors.black, Colors.black87]);
final example02 = ExamplePage(
  viewModel: viewModel02,
);



/// Example 04
final customWidth04 =
CustomSliderWidths(trackWidth: 4, progressBarWidth: 20, shadowWidth: 40);
final customColors04 = CustomSliderColors(
    trackColor: HexColor('#CCFF63'),
    progressBarColor: HexColor('#00FF89'),
    shadowColor: HexColor('#B0FFDA'),
    shadowMaxOpacity: 0.5, //);
    shadowStep: 20);
final info04 = InfoProperties(
    bottomLabelStyle: TextStyle(
        color: HexColor('#6DA100'), fontSize: 20, fontWeight: FontWeight.w600),
    bottomLabelText: 'Temp.',
    mainLabelStyle: TextStyle(
        color: HexColor('#54826D'),
        fontSize: 30.0,
        fontWeight: FontWeight.w600),
    modifier: (double value) {
      final temp = value.toInt();
      return '$temp ˚C';
    });
final CircularSliderAppearance appearance04 = CircularSliderAppearance(
    customWidths: customWidth04,
    customColors: customColors04,
    infoProperties: info04,
    startAngle: 90,
    angleRange: 90,
    size: 200.0,
    animationEnabled: true);
final viewModel04 = ExampleViewModel(
    appearance: appearance04,
    min: 0,
    max: 40,
    value: 27,
    pageColors: [Colors.white, HexColor('#F1F1F1')]);
final example04 = ExamplePage(
  viewModel: viewModel04,
);

/// Example 05
final customWidth05 =
CustomSliderWidths(trackWidth: 4, progressBarWidth: 45, shadowWidth: 70);
final customColors05 = CustomSliderColors(
    dotColor: HexColor('#FFB1B2'),
    trackColor: HexColor('#E9585A'),
    progressBarColors: [HexColor('#FB9967'), HexColor('#E9585A')],
    shadowColor: HexColor('#FFB1B2'),
    shadowMaxOpacity: 0.05);
final info05 = InfoProperties(
    topLabelStyle: TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
    topLabelText: 'Elapsed',
    bottomLabelStyle: TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
    bottomLabelText: 'time',
    mainLabelStyle: TextStyle(
        color: Colors.white, fontSize: 50.0, fontWeight: FontWeight.w600),
    modifier: (double value) {
      final time = printDuration(Duration(seconds: value.toInt()));
      return '$time';
    });
final CircularSliderAppearance appearance05 = CircularSliderAppearance(
    customWidths: customWidth05,
    customColors: customColors05,
    infoProperties: info05,
    startAngle: 270,
    angleRange: 360,
    size: 350.0);
final viewModel05 = ExampleViewModel(
    appearance: appearance05,
    min: 0,
    max: 86400,
    value: 67459,
    pageColors: [Colors.black, Colors.black87]);
final example05 = ExamplePage(
  viewModel: viewModel05,
);

/// Example 06
final customWidth06 =
CustomSliderWidths(trackWidth: 4, progressBarWidth: 40, shadowWidth: 70);
final customColors06 = CustomSliderColors(
    dotColor: Colors.white.withOpacity(0.1),
    trackColor: HexColor('#F9EBE0').withOpacity(0.2),
    progressBarColors: [
      HexColor('#A586EE').withOpacity(0.3),
      HexColor('#F9D3D2').withOpacity(0.3),
      HexColor('#BF79C2').withOpacity(0.3)
    ],
    shadowColor: HexColor('#7F5ED9'),
    shadowMaxOpacity: 0.05);

final CircularSliderAppearance appearance06 = CircularSliderAppearance(
    customWidths: customWidth06,
    customColors: customColors06,
    startAngle: 180,
    angleRange: 360,
    size: 300.0);
final viewModel06 = ExampleViewModel(
    innerWidget: (double value) {
      return Transform.rotate(
          angle: degreeToRadians(value),
          child: Align(
            alignment: Alignment.center,
            child: Container(
                width: value / 2.5,
                height: value / 2.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        HexColor('#F9D3D2').withOpacity(value / 360),
                        HexColor('#BF79C2').withOpacity(value / 360)
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      tileMode: TileMode.clamp),
                  // borderRadius: BorderRadius.all(
                  //   Radius.circular(value / 6),
                  // ),
                )),
          ));
    },
    appearance: appearance06,
    min: 0,
    max: 360,
    value: 45,
    pageColors: [HexColor('#4825FF'), HexColor('#FFCAD2')]);
final example06 = ExamplePage(
  viewModel: viewModel06,
);

/// Example 07
final customWidth07 =
CustomSliderWidths(trackWidth: 4, progressBarWidth: 40, shadowWidth: 70);
final customColors07 = CustomSliderColors(
    dotColor: Colors.white.withOpacity(0.1),
    trackColor: HexColor('#F9EBE0').withOpacity(0.2),
    progressBarColors: [
      HexColor('#A586EE').withOpacity(0.3),
      HexColor('#F9D3D2').withOpacity(0.3),
      HexColor('#BF79C2').withOpacity(0.3)
    ],
    shadowColor: HexColor('#7F5ED9'),
    shadowMaxOpacity: 0.05);

final CircularSliderAppearance appearance07 = CircularSliderAppearance(
    customWidths: customWidth07,
    customColors: customColors07,
    startAngle: 180,
    angleRange: 360,
    size: 300.0);
final viewModel07 = ExampleViewModel(
    innerWidget: (double value) {
      return Transform.rotate(
          angle: degreeToRadians(value),
          child: Align(
            alignment: Alignment.center,
            child: Container(
                width: value / 2.5,
                height: value / 2.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        HexColor('#F9D3D2').withOpacity(value / 360),
                        HexColor('#BF79C2').withOpacity(value / 360)
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      tileMode: TileMode.clamp),
                  // borderRadius: BorderRadius.all(
                  //   Radius.circular(value / 6),
                  // ),
                )),
          ));
    },
    appearance: appearance07,
    min: 0,
    max: 360,
    value: 45,
    pageColors: [HexColor('#4825FF'), HexColor('#FFCAD2')]);
final example07 = ExamplePage(
  viewModel: viewModel07,
);

String printDuration(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}*/
