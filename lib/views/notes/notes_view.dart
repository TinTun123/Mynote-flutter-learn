import 'package:flutter/material.dart';
import 'package:mynote/constants/routes.dart';
import 'package:mynote/enums/menu_actions.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/services/crud/note_service.dart';
import 'package:mynote/utilities/dialogs/logout_dialog.dart';
import 'package:mynote/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NoteService _noteService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState () {
    _noteService = NoteService();
    _noteService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            }, 
            icon: const Icon(Icons.add)
            ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);

                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false) ;
                  }
                  break;
      
              }
            },
            surfaceTintColor: Colors.white,
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("Logout")
                  )
              ];
            },
          )
        ]  
      ),
      body: FutureBuilder(
          future: _noteService.getOrCreateUser(email: userEmail), 
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _noteService.allnotes, 
                  builder:  (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          return NotesListView(
                            notes: allNotes, 
                            onDelete: (note) async {
                              await _noteService.deleteNote(noteId: note.id);
                            });
                        } else {
                          return CircularProgressIndicator();
                        }
                        return const Text('Waiting all notes');
                      default:
                        return CircularProgressIndicator();
                    }
                  }
                  );

              default:
                return const CircularProgressIndicator();

            }

          }
        ),

    );
  }
}

Future<bool> showDialogLogout(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
          }, 
            child: const Text("Log out!")),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            }, 
            child: const Text("Cancel!"))
        ],
      );
    }
    ).then((value) => value ?? false);
}