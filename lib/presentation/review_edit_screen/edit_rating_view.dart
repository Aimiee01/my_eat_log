import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class EditRatingView extends StatefulWidget {
  const EditRatingView({
    Key? key,
    required this.initialRating,
    required this.newRating,
  }) : super(key: key);

  final double initialRating;
  final ValueChanged<double> newRating;

  @override
  _EditRatingViewState createState() => _EditRatingViewState();
}

class _EditRatingViewState extends State<EditRatingView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '評価   ',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          RatingBar.builder(
            initialRating: widget.initialRating,
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 2),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            // 星がタップされたときの処理
            onRatingUpdate: widget.newRating,
          ),
        ],
      ),
    );
  }
}
