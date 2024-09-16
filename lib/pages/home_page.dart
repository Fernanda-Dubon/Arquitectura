import 'package:flutter/material.dart';
import 'package:simple_todo/utils/todo_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late TabController _tabController;

  List<List<dynamic>> toDoList = [
    ['Contestar el foro de Física 2', true],
    ['Leer "Un viaje al centro de la Tierra"', true],
    ['Finalizar el proyecto final de programación', false],
    ['Repasar para el examen final de Cálculo', false],
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void checkBoxChanged(int index) {
    setState(() {
      toDoList[index][1] = !toDoList[index][1];
    });
  }

  void saveNewTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        toDoList.add([_controller.text, false]);
        _controller.clear();
      });
    }
  }

  void deleteTask(int index) {
    setState(() {
      toDoList.removeAt(index);
    });
  }

  Future<void> _editTask(int index) async {
    final TextEditingController editController = TextEditingController(text: toDoList[index][0]);
    
    final bool? shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: 'Introduce el nuevo texto de la tarea',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Respuesta no
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Respuesta sí
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );

    if (shouldUpdate == true) {
      setState(() {
        toDoList[index][0] = editController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar tareas pendientes y finalizadas
    List<List<dynamic>> pendingTasks = toDoList.where((task) => !task[1]).toList();
    List<List<dynamic>> completedTasks = toDoList.where((task) => task[1]).toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: const Text('To Do List'),
        backgroundColor: const Color.fromARGB(255, 68, 67, 70),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,  // Color del texto seleccionado
          unselectedLabelColor: Colors.grey,  // Color del texto no seleccionado
          indicatorColor: Colors.white,  // Color del indicador de la pestaña seleccionada
          tabs: const [
            Tab(text: 'Pendientes'),
            Tab(text: 'Finalizadas'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pestaña de tareas pendientes
                ListView.builder(
                  itemCount: pendingTasks.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TodoList(
                      taskName: pendingTasks[index][0],
                      taskCompleted: pendingTasks[index][1],
                      onChanged: (value) => checkBoxChanged(toDoList.indexOf(pendingTasks[index])),
                      deleteFunction: (context) => deleteTask(toDoList.indexOf(pendingTasks[index])),
                      editFunction: () => _editTask(toDoList.indexOf(pendingTasks[index])), // Pasar la función de edición
                    );
                  },
                ),
                // Pestaña de tareas finalizadas
                ListView.builder(
                  itemCount: completedTasks.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TodoList(
                      taskName: completedTasks[index][0],
                      taskCompleted: completedTasks[index][1],
                      onChanged: (value) => checkBoxChanged(toDoList.indexOf(completedTasks[index])),
                      deleteFunction: (context) => deleteTask(toDoList.indexOf(completedTasks[index])),
                      editFunction: () => _editTask(toDoList.indexOf(completedTasks[index])), // Pasar la función de edición
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Añadir nueva tarea',
                      filled: true,
                      fillColor: const Color.fromARGB(255, 168, 168, 168),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 4, 0, 12),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: saveNewTask,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
