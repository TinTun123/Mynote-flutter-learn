import 'package:flutter/material.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/services/crud/note_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  late final NoteService _noteService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _noteService = NoteService();
    _textController = TextEditingController();
    
    super.initState();

  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }

    final text = _textController.text;
    await _noteService.updateNote(note: note, text: text);

  }

  void _setUpTextControllerListner() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    print("Extract user from FB: $currentUser");
    final email = currentUser.email!;
    final owner = await _noteService.getUser(email: email);
    print("DatabaseUser model: $owner");
    return await _noteService.createNote(user: owner);

  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
       _noteService.deleteNote(noteId: note.id);
    } 
  }

  void _saveNoteIfTextNotEmpty () async {
    final note = _note;
    final text = _textController.text;


    if (note != null && text.isNotEmpty) {
      await _noteService.updateNote(note: note, text: text);
    }

  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
      ),
      body: FutureBuilder(
        future: createNewNote(), 
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
             
              _note = snapshot.data as DatabaseNote;
              _setUpTextControllerListner();

              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Enter your note here"
                ),
              );
             
            default:
              return const CircularProgressIndicator();
          }
        }),
    );
  }
}