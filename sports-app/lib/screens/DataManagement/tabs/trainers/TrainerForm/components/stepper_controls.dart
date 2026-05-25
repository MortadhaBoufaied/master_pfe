import 'package:flutter/material.dart';

class PageIndicatorAndButtons extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool Function() isFormValid;
  final VoidCallback submitForm;

  const PageIndicatorAndButtons({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onBack,
    required this.isFormValid,
    required this.submitForm,
  }) : super(key: key);

  @override
  _PageIndicatorAndButtonsState createState() =>
      _PageIndicatorAndButtonsState();
}

class _PageIndicatorAndButtonsState extends State<PageIndicatorAndButtons> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPageIndicator(),
        const SizedBox(height: 6),
        _buildButtons(),
      ],
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          ElevatedButton(
            onPressed: widget.currentStep > 0 ? widget.onBack : null,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor:
              widget.currentStep == 0 ? Colors.grey : Colors.teal,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(''),
          ),
          // Next / Save Button
          ElevatedButton(
            onPressed: widget.currentStep == (widget.totalSteps - 1)
                ? (widget.isFormValid() ? widget.submitForm : null)
                : widget.onNext,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: widget.currentStep == (widget.totalSteps - 1)
                  ? Colors.green
                  : Colors.teal,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(widget.currentStep == (widget.totalSteps - 1)
                ? ''
                : ''),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.totalSteps, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.currentStep == index ? Colors.teal : Colors.grey,
          ),
        );
      }),
    );
  }
}


