import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'home_page.dart';


class ExampleViewModel {
  final List<Color> pageColors;
  final CircularSliderAppearance appearance;
  final double min;
  final double max;
  final double value;
  final InnerWidget innerWidget;

  ExampleViewModel(
      {@required this.pageColors,
        @required this.appearance,
        this.min,
        this.max,
        this.value,
        this.innerWidget});
}




class ExamplePage extends StatelessWidget {

  final Function(int)currentValue;   //回傳int
  //final Function changeValeByText;
  final ExampleViewModel viewModel;
  SleekCircularSlider sleekcircularslider;
  ExamplePage({
    Key key,
    //this.changeValeByText,
    this.currentValue,
    @required this.viewModel,
  }) : super(key: key);

  ///創出SleekCircularSlider
  void createSleekCircularSlider(){
    final sleekcircularslider_local = SleekCircularSlider(
      onChangeStart: (double value) {
        //print('$value start');
      },
      onChangeEnd: (double value) {
        print('$value end');
        currentValue(value.ceil());
      },
      onChange: (double value){
        //print('$value onchange');
      },
      innerWidget: viewModel.innerWidget,
      appearance: viewModel.appearance,
      min: viewModel.min,
      max: viewModel.max,
      initialValue: viewModel.value,
    );
    sleekcircularslider = sleekcircularslider_local;
  }

  void valuechange(int val){
    sleekcircularslider.sf.changeAngleViaMessage(val);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          //背景的顏色
          Container(
            decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: viewModel.pageColors,
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                tileMode: TileMode.clamp)),
          ),
        Container(
          child: SafeArea(
          child: Center(
              child:sleekcircularslider
                /*SleekCircularSlider(
                onChangeStart: (double value) {
                  //print('$value start');
                },
                onChangeEnd: (double value) {
                  //print('$value end');
                  currentValue(value.ceil());
                },
                onChange: (double value){
                  //print('$value onchange');
                },
                innerWidget: viewModel.innerWidget,
                appearance: viewModel.appearance,
                min: viewModel.min,
                max: viewModel.max,
                initialValue: viewModel.value,
              )*/),
        ),
        ),
        ],
      ),
    );
  }
}