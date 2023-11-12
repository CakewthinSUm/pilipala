import 'package:flutter/material.dart';
import 'package:pilipala/utils/feed_back.dart';

class MenuRow extends StatelessWidget {
  final bool? loadingStatus;
  const MenuRow({
    Key? key,
    this.loadingStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.only(top: 9, bottom: 9, left: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          ActionRowLineItem(
            onTap: () => {},
            loadingStatus: loadingStatus,
            text: '推荐',
            selectStatus: false,
          ),
          const SizedBox(width: 8),
          ActionRowLineItem(
            onTap: () => {},
            loadingStatus: loadingStatus,
            text: '弹幕',
            selectStatus: false,
          ),
          const SizedBox(width: 8),
          ActionRowLineItem(
            onTap: () => {},
            loadingStatus: loadingStatus,
            text: '评论列表',
            selectStatus: false,
          ),
          const SizedBox(width: 8),
          ActionRowLineItem(
            onTap: () => {},
            loadingStatus: loadingStatus,
            text: '播放列表',
            selectStatus: false,
          ),
        ]),
      ),
    );
  }

  Widget actionRowLineItem(
      context, Function? onTap, bool? loadingStatus, String? text,
      {bool selectStatus = false}) {
    return Material(
      color: selectStatus
          ? Theme.of(context).highlightColor.withOpacity(0.2)
          : Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => {
          feedBack(),
          onTap!(),
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 5.5, 13, 4.5),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            border: Border.all(
              color: selectStatus
                  ? Colors.transparent
                  : Theme.of(context).highlightColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                opacity: loadingStatus! ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  text!,
                  style: TextStyle(
                      fontSize: 13,
                      color: selectStatus
                          ? Theme.of(context).colorScheme.onBackground
                          : Theme.of(context).colorScheme.outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionRowLineItem extends StatelessWidget {
  final bool? selectStatus;
  final Function? onTap;
  final bool? loadingStatus;
  final String? text;

  const ActionRowLineItem(
      {super.key,
      this.selectStatus,
      this.onTap,
      this.text,
      this.loadingStatus = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selectStatus!
          ? Theme.of(context).colorScheme.secondaryContainer
          : Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => {
          feedBack(),
          onTap!(),
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 5.5, 13, 4.5),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            border: Border.all(
              color: selectStatus!
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.secondaryContainer,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                opacity: loadingStatus! ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  text!,
                  style: TextStyle(
                      fontSize: 13,
                      color: selectStatus!
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : Theme.of(context).colorScheme.outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
