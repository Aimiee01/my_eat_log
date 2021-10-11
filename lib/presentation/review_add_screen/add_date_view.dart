import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddDateView extends StatefulWidget {
  const AddDateView({
    Key? key,
    required this.visitedDateChanged,
    this.visitedDate,
  }) : super(key: key);

  final ValueChanged<String> visitedDateChanged;
  final String? visitedDate;

  @override
  _AddDateViewState createState() {
    return _AddDateViewState();
  }
}

class _AddDateViewState extends State<AddDateView> {
  @override
  void initState() {
    // Firebaseに保存済みの来店日を表示
    if (widget.visitedDate != null) {
      _labelText = widget.visitedDate!;
    }
    super.initState();
    debugPrint(widget.visitedDate);
  }

  var _labelText = '来店日を選択してください';

  @override
  Widget build(BuildContext context) {
    Future<void> _selectDate(BuildContext context) async {
      final selected = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime(2025),
      );

      if (selected != null) {
        setState(() {
          _labelText = DateFormat.yMMMd().format(selected);
        });
        widget.visitedDateChanged(_labelText);
      }
    }

    return ListTile(
      leading: const Icon(
        Icons.date_range,
      ),
      title: Text(_labelText),
      // 参考：visitedDateがあれば表示、なければ'来店日を〜'を表示
      // title: Text(widget.reviewDoc?.data().visitedDate ?? '来店日を選択してください'),
      onTap: () => _selectDate(context),
      minLeadingWidth: 6,
      contentPadding: EdgeInsets.zero,
    );
  }
}
