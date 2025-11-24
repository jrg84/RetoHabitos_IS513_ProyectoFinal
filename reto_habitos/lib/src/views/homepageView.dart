// lib/src/views/home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reto_habitos/src/views/editView.dart';
import '../models/HabitosModel.dart';
import '../providers/habitosprovider.dart';
import '../views/habito_timer_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HabitoProvider _provider = HabitoProvider();
  final TextEditingController _searchController = TextEditingController();
  String _filtro = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 156, 175, 136),
        elevation: 0,
        title: const Text(
          'Reto de Hábitos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // input de busqueda
          Container(
            color: const Color.fromARGB(255, 156, 175, 136),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _filtro = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar hábitos...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 99, 110, 114)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          
          Expanded(
            child: StreamBuilder<List<Habito>>(
              stream: _provider.getHabitosUsuario(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 156, 175, 136),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar hábitos',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final habitos = snapshot.data ?? [];
                // final habitos = [];
                
                // flitrar habitos
                final habitosFiltrados = habitos.where((h) {
                  return h.nombre.toLowerCase().contains(_filtro);
                }).toList();

                if (habitosFiltrados.isEmpty) {
                  if (_filtro.isNotEmpty) {
                    return Center(
                      child: Text(
                        'No se encontraron hábitos',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: habitosFiltrados.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Dismissible(
                          key: Key(habitosFiltrados[index].id!),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              // editar
                              context.push(
                                '/editar/${habitosFiltrados[index].id}',
                                extra: habitosFiltrados[index],
                              );
                              return false;
                            }

                            // eliminar
                            return await _showDeleteConfirmation(
                              context,
                              habitosFiltrados[index],
                            );
                          },
                          onDismissed: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              await FirebaseFirestore.instance
                                  .collection('habitos')
                                  .doc(habitosFiltrados[index].id)
                                  .delete();
                            }
                          },
                          background: Container(
                            padding: const EdgeInsets.only(left: 16),
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          secondaryBackground: Container(
                            padding: const EdgeInsets.only(right: 16),
                            color: const Color.fromARGB(255, 161, 136, 199),
                            alignment: Alignment.centerRight,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Editar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                          child: _buildHabitoCard(habitosFiltrados[index]),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          
        ],
        
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navegar a crear hábito
          context.push('/crear');
        },
        backgroundColor: const Color.fromARGB(255, 156, 175, 136),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, Habito habito) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Eliminar Hábito'),
          content: Text('¿Estás seguro al eliminar "${habito.nombre}"? \nSe eliminará todo el progreso y datos del reto'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawer() {
    // final user = FirebaseAuth.instance.currentUser;
    
    return Drawer(
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
        children: [
          // Header con perfil
          // UserAccountsDrawerHeader(
          //   decoration: const BoxDecoration(
          //     color: Color(0xFF9CAF88),
          //   ),
          //   currentAccountPicture: CircleAvatar(
          //     backgroundColor: Colors.white,
          //     // backgroundImage: user?.photoURL != null
          //     //     ? NetworkImage(user!.photoURL!)
          //     //     : null,
          //     // child: user?.photoURL == null
          //     //     ? const Icon(Icons.person, size: 40, color: Color(0xFF9CAF88))
          //     //     : null,
          //   ),
          //   accountName: Text( 'Usuario',
          //     // user?.displayName ?? 'Usuario',
          //     style: const TextStyle(
          //       fontWeight: FontWeight.bold,
          //       fontSize: 18,
          //     ),
          //   ),
          //   accountEmail: Text(user?.email ?? ''),
          // ),

          // menu
          ListTile(
            leading: const Icon(Icons.home, color: Color.fromARGB(255, 156, 175, 136)),
            title: const Text(
              'Inicio',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            selected: true,
            selectedTileColor: const Color.fromARGB(51, 184, 224, 210),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const Spacer(),

          const Divider(),

          // cerrar sesion
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    )
    );

  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustración
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Color.fromARGB(77, 184, 224, 210),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.self_improvement,
                size: 100,
                color: Color.fromARGB(255, 156, 175, 136),
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Aún no tienes hábitos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 45, 52, 54),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Crea tu primer hábito para empezar un nuevo reto',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // ElevatedButton.icon(
            //   onPressed: () {
            //     context.push('/habitos/crear');
            //   },
            //   icon: const Icon(Icons.add),
            //   label: const Text('Crear mi primer hábito'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: const Color(0xFF9CAF88),
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 32,
            //       vertical: 16,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitoCard(Habito habito) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // navegacion a detalle del hábito
          //context.push('/habitos/${habito.id}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HabitoTimerView(habito: habito),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // grafico 
              SizedBox(
                width: 80,
                height: 80,
                child: _buildDonutChart(habito),
              ),
              
              const SizedBox(width: 16),
              
              // informacion de hábito
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre     
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Color.fromARGB(255, 156, 175, 136),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${habito.diasRealizados}/30 días',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 99, 110, 114),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    
                    Row(
                      children: [
                        const Text(
                          '🔥',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${habito.streakActual} días seguidos',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 99, 110, 114),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color.fromARGB(255, 212, 165, 116),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Termina: ${_formatearFecha(habito.fechaFin)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 99, 110, 114),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // dias restantes
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(36, 169, 65, 0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column( 
                  children: [
                    const Text(
                      'Faltan',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color.fromARGB(255, 99, 110, 114),
                      ),
                    ),
                    Text(
                      '${habito.diasRestantes}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 45, 52, 54),
                      ),
                    ),
                    const Text(
                      'días',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color.fromARGB(255, 99, 110, 114),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDonutChart(Habito habito) {
    final porcentaje = habito.porcentajeCompletado;

    const coloresChartArray = [
      Color.fromARGB(255, 156, 175, 136),
      Color.fromARGB(255, 77, 51, 30),
      Color.fromARGB(255, 251, 203, 91),
      // // Color.fromARGB(255, 255, 118, 117),
      Color.fromARGB(255, 186, 172, 250),
      Color.fromARGB(255, 235, 121, 14),
    ];
    
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 0,
            centerSpaceRadius: 25,
            startDegreeOffset: -90,
            sections: [
              // Completado
              PieChartSectionData(
                value: habito.diasRealizados.toDouble(),
                // color: const Color.fromARGB(255, 156, 175, 136),
                color: coloresChartArray[habito.id.hashCode % coloresChartArray.length],
                radius: 10,
                showTitle: false,
              ),
              // Restante
              PieChartSectionData(
                value: (30 - habito.diasRealizados).toDouble(),
                color: const Color.fromARGB(255, 224, 224, 224),
                radius: 10,
                showTitle: false,
              ),
            ],
          ),
        ),

        Text(
          '${porcentaje.toInt()}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 45, 52, 54),
          ),
        ),
      ],
    );
  }

  String _formatearFecha(DateTime fecha) {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]}';
  }
}