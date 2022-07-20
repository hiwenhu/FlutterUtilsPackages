import 'dart:io';

import 'package:flutter/material.dart';

class FileListTile extends StatelessWidget {
  const FileListTile({
    Key? key,
    required this.file,
    this.onToggleCompleted,
    this.onDismissed,
    this.onTap,
  }) : super(key: key);

  final File file;
  final ValueChanged<bool>? onToggleCompleted;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionColor = theme.textTheme.caption?.color;

    return Dismissible(
      key: Key('todoListTile_dismissible_${file.path}'),
      onDismissed: onDismissed,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.error,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(
          Icons.delete,
          color: Color(0xAAFFFFFF),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          file.absolute.path,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // style: !file.isCompleted
          //     ? null
          //     : TextStyle(
          //         color: captionColor,
          //         decoration: TextDecoration.lineThrough,
          //       ),
        ),
        // subtitle: Text(
        //   file.description,
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        // ),
        // leading: Checkbox(
        //   shape: const ContinuousRectangleBorder(
        //     borderRadius: BorderRadius.all(Radius.circular(8)),
        //   ),
        //   value: file.isCompleted,
        //   onChanged: onToggleCompleted == null
        //       ? null
        //       : (value) => onToggleCompleted!(value!),
        // ),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}
