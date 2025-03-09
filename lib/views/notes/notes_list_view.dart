import 'package:flutter/material.dart';
import 'package:mynote/constants/routes.dart';
import 'package:mynote/services/crud/note_service.dart';
import 'package:mynote/utilities/dialogs/delete_dialog.dart';

typedef DeleteNoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final DeleteNoteCallback onDelete;

  const NotesListView({super.key, required this.notes, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.text, maxLines: 1, softWrap: true, overflow: TextOverflow.ellipsis,),
                onTap: () {
                  Navigator.of(context).pushNamed(newNoteRoute, arguments: note);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final shouldDelete = await showDeleteDialog(context);
                    if (shouldDelete) {
                      onDelete(note);
                    }
                    
                  },
                ),
              );
            },
          );
  }
}