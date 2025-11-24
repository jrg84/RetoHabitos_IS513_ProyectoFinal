// lib/src/views/crear_habito_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/HabitosModel.dart';
import '../providers/habitosprovider.dart';

class CrearHabitoPage extends StatefulWidget {
  const CrearHabitoPage({super.key});

  @override
  State<CrearHabitoPage> createState() => _CrearHabitoPageState();
}

class _CrearHabitoPageState extends State<CrearHabitoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _duracionController = TextEditingController();
  final HabitoProvider _provider = HabitoProvider();
  
  bool _isLoading = false;
  DateTime? _fechaInicio;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 156, 175, 136),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Crear Hábito',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 156, 175, 136),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(77, 255, 255, 255),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.self_improvement,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nuevo Reto',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea un nuevo reto para un hábito',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(230, 255, 255, 255),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Nombre del Hábito'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _nombreController,
                      hint: 'Ej: Meditación diaria',
                      icon: Icons.edit_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un nombre';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Descripción'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _descripcionController,
                      hint: 'Describe tu hábito...',
                      icon: Icons.description_rounded,
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Duración diaria sugerida (minutos)'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _duracionController,
                      hint: 'Ej: 10',
                      icon: Icons.timer_rounded,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la duración';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Fecha de Inicio'),
                    const SizedBox(height: 12),
                    _buildDateSelector(),
                    
                    const SizedBox(height: 32),
                    
                    _buildInfoCard(),
                    
                    const SizedBox(height: 32),
                    
                    _buildCreateButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 45, 52, 54),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(13, 0, 0, 0),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          color: Color.fromARGB(255, 45, 52, 54),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color.fromARGB(255, 189, 189, 189),
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(26, 156, 175, 136),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: Color.fromARGB(255, 156, 175, 136),
              size: 24,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 156, 175, 136),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(13, 0, 0, 0),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(26, 161, 136, 199),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color.fromARGB(255, 161, 136, 199),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _fechaInicio == null
                      ? 'Seleccionar fecha'
                      : _formatearFecha(_fechaInicio!),
                  style: TextStyle(
                    fontSize: 16,
                    color: _fechaInicio == null
                        ? const Color.fromARGB(255, 189, 189, 189)
                        : const Color.fromARGB(255, 45, 52, 54),
                    fontWeight: _fechaInicio == null
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color.fromARGB(255, 189, 189, 189),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 184, 224, 210),
            Color.fromARGB(255, 161, 136, 199),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(77, 184, 224, 210),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color.fromARGB(77, 255, 255, 255),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'El reto para este habito durará 30 días desde la fecha de inicio',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _crearHabito,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 156, 175, 136),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: const Color.fromARGB(102, 156, 175, 136),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Crear Hábito',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 156, 175, 136),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color.fromARGB(255, 45, 52, 54),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fechaInicio = picked;
      });
    }
  }

  Future<void> _crearHabito() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final fechaInicio = _fechaInicio ?? DateTime.now();
      final fechaFin = fechaInicio.add(const Duration(days: 30));

      final nuevoHabito = Habito(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        duracion: int.parse(_duracionController.text),
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        userId: 'default-user',
      );

      await _provider.crearHabito(nuevoHabito);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Hábito creado exitosamente!'),
            backgroundColor: Color.fromARGB(255, 156, 175, 136),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear hábito: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatearFecha(DateTime fecha) {
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]}, ${fecha.year}';
  }
}