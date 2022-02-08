import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AddRatingView extends StatefulWidget {
  const AddRatingView({
    Key? key,
    required this.newRatingStarNum,
  }) : super(key: key);

  final ValueChanged<double> newRatingStarNum;

  @override
  _AddRatingViewState createState() => _AddRatingViewState();
}

class _AddRatingViewState extends State<AddRatingView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          RatingBar.builder(
            initialRating: 0,
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 30,
            itemPadding: const EdgeInsets.symmetric(horizontal: 2),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            // Ratingが更新された時にnewRatingStarNumを呼び出し
            // 値が変更されたことを知らせる
            onRatingUpdate: widget.newRatingStarNum,
          ),
        ],
      ),
    );
  }
}
