import 'package:flutter/material.dart';

class FormBasicDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FormBasicDemoState();
}

class _FormBasicDemoState extends State<FormBasicDemo> {
//Su dung global key de truy cap form
  final _formKey = GlobalKey<FormState>();
  String? _name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Form co ban"),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          //Form la widget chua va quan li cac truong nhap loei
          //Key dc su dung de truy cap vao trang thai cua form
          //Phuong thuc validate() kiem tra tinh hop le cua tat ca truong
          //Phuong thuc sav() goi ham onSaved cua moi truong
          //Phuong thuc reset() dat lai gia tri cua tat ca truong
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Ho va ten",
                      hintText: "Nhap ho va ten cua ban",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) {
                      _name = value;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Xin chao $_name"))
                          );
                        }
                      }, child: Text("Submit")),
                      SizedBox(width: 20,),
                      ElevatedButton(onPressed: () {
                        _formKey.currentState!.reset();
                        setState(() {
                          _name = null;
                        });
                      }, child: Text("Reset")),
                    ],
                  )
                ],

              )
          ),
        )
    );
  }

}