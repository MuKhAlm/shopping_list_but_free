import 'dart:math';

import 'package:flutter/material.dart';

/// Displays a form that allows the user to enter text and submit.
///
/// Invokes [onSubmit] when the user submits the form.
class AddEntity extends StatefulWidget {
  /// Code to be invoked when the form is submitted,
  ///
  /// First parameter is the value of the input field.
  final void Function(String) onSubmit;

  final String inputFieldHintText;

  const AddEntity({
    required this.onSubmit,
    this.inputFieldHintText = '',
    Key? key,
  }) : super(key: key);

  @override
  State<AddEntity> createState() => _AddEntityState();
}

class _AddEntityState extends State<AddEntity> {
  String _newEntityName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          Center(
            child: SizedBox(
              width: min(MediaQuery.of(context).size.width - 10, 300),
              height: MediaQuery.of(context).size.height / 3,
              child: Card(
                elevation: 20,
                child: Column(
                  children: [
                    Row(
                      children: [
                        BackButton(
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Form(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextFormField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: widget.inputFieldHintText,
                                ),
                                initialValue: _newEntityName,
                                onChanged: (value) {
                                  setState(() {
                                    _newEntityName = value;
                                  });
                                },
                                onFieldSubmitted: (value) {
                                  widget.onSubmit(_newEntityName);
                                },
                              ),
                              IconButton(
                                tooltip: 'Submit',
                                onPressed: (() {
                                  widget.onSubmit(_newEntityName);
                                }),
                                icon: const Icon(
                                  Icons.done,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
